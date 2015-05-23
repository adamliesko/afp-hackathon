class Judge < ActiveRecord::Base
has_many :admissions

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :sorted_by,
      :search_query
    ]
  )

scope :with_country_id, lambda { |country_ids|
  where(country_id: [*country_ids])
}

scope :search_query, lambda { |query|
  return nil  if query.blank?


  # condition query, parse into individual keywords
  terms = query.downcase.split(/\s+/)

  # replace "*" with "%" for wildcard searches,
  # append '%', remove duplicate '%'s
  terms = terms.map { |e|
    (e.gsub('*', '%') + '%').gsub(/%+/, '%')
  }
  # configure number of OR conditions for provision
  # of interpolation arguments. Adjust this if you
  # change the number of OR conditions.
  num_or_conds = 2
  where(
    terms.map { |term|
      "LOWER(name) LIKE ? OR LOWER(court) LIKE ?"
    }.join(' AND '),
    *terms.map { |e| [e] * num_or_conds }.flatten
  )
}

scope :sorted_by, lambda { |sort_option|
  # extract the sort direction from the param value.
  direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
  case sort_option.to_s
  when /^court_/

    order("judges.court #{ direction }")
    when /^name_/

    # Simple sort on the name colums
    order("LOWER(reverse(split_part(judges.name, ' ', 1))) #{ direction }")
  else
    raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
  end
}

  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Name (z-a)', 'name_desc'],
      ['Court (a-z)', 'court_asc'],
      ['Court (z-a)', 'court_desc'],
    ]
  end

  def parse
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'

    (1..2873).each do |i| #2873
      begin
        page = Nokogiri::HTML(open("http://www.sudnarada.gov.sk/mps/Priznanie#{i}.html"))
      rescue OpenURI::HTTPError
        puts "404"
      else
        judge_name = page.css("table")[3].css("tr td span")[1].text
        judge_court = page.css("table")[3].css("tr td span")[3].text
        year = page.css("table")[3].css("tr td span")[7].text
        puts judge_name + " " + judge_court
        judge = Judge.find_or_create_by(name: judge_name, court: judge_court)
        admission = Admission.create(judge_id: judge.id, year: year)
        puts "STRANKA http://www.sudnarada.gov.sk/mps/Priznanie#{i}.html"
        (0..4).each do |table_index|
          category2 = page.css("table")[4].css("tr td h3")[table_index].text

          #tabulka pre konkretny typ admissionu
          inner_table = page.css("table")[4].css("tr td table")[table_index]

          if (!inner_table.nil?)

            #riadky v danej tabulke
            rows = inner_table.css("tr")

            @admission_type = 0
            case category2
              when "Nehnuteľný majetok"
                @admission_type = 1
                rows.each do |row|
                  if (row.css("div.sbjp").text != "")
                    puts "ADMISSION TYPE #{@admission_type}: \n Nehnutelnost: #{row.css("div.sbjp")[0].text}
                         \n Nadobudnutie: #{row.css("div.sbjp")[1].text}
                         \n Datum: #{row.css("div.sbjp")[2].text}
                         \n Zmena: #{row.css("div.sbjp")[3].text}"
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, change: row.css("div.sbjp")[3].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text, category: "estate")
                  end
                end
              when "Hnuteľný majetok"
                @admission_type = 2
                rows.each do |row|
                  if (row.css("div.sbjp").text != "")
                    puts "ADMISSION TYPE #{@admission_type}: \n Hnutelnost: #{row.css("div.sbjp")[0].text}
                         \n Nadobudnutie: #{row.css("div.sbjp")[1].text}
                         \n Datum: #{row.css("div.sbjp")[2].text}
                         \n Cena: #{row.css("div.sbjp")[3].text}
                         \n Zmena: #{row.css("div.sbjp")[4].text}"
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, value: row.css("div.sbjp")[3].text, change: row.css("div.sbjp")[4].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text, category: "chattel")
                  end
                end
              when "Majetkové práva"
                @admission_type = 3
                rows.each do |row|
                  if (row.css("div.sbjp").text != "" and !row.css("div.sbjp")[4].nil?)
                    puts "ADMISSION TYPE #{@admission_type}: \n Popis prava: #{row.css("div.sbjp")[0].text}
                         \n Nadobudnutie: #{row.css("div.sbjp")[1].text}
                         \n Datum: #{row.css("div.sbjp")[2].text}
                         \n Cena: #{row.css("div.sbjp")[3].text}
                         \n Zmena: #{row.css("div.sbjp")[4].text}"
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, value: row.css("div.sbjp")[3].text, change: row.css("div.sbjp")[4].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text, category: "property_rights")
                  end
                end
              when "Závazky predmetom ktorých je peňažné plnenie"
                @admission_type = 4
                rows.each do |row|
                  if (row.css("div.sbjp").text != "")
                    puts "ADMISSION TYPE #{@admission_type}: \n Zavazok: #{row.css("div.sbjp")[0].text}
                         \n Nadobudnutie: #{row.css("div.sbjp")[1].text}
                         \n Datum: #{row.css("div.sbjp")[2].text}
                         \n Zmena: #{row.css("div.sbjp")[3].text}"
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, change: row.css("div.sbjp")[3].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text, category: "monetary_obligation")
                  end
                end
            end
          end
          # inner_tables.each do |table|
          #   rows = inner_tables.css("tr")
          #   puts "ROW #{rows}"
          #   # rows.each do |row|
          #   #   puts "ROW #{row}"
          #   # end
          # end
        end

      end
    end

  end

  def parse_old(data_year)
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'

    (1..2000).each do |i| #2873
      begin
        page = Nokogiri::HTML(open("http://wwwold.justice.sk/tma.aspx?sudcaID=#{i}&rok=31.12.#{data_year}"))
      rescue OpenURI::HTTPError
        puts "404 YEAR: #{data_year} http://wwwold.justice.sk/tma.aspx?sudcaID=#{i}&rok=31.12.#{data_year}"
      else
        judge_name = page.css("form#Form1 div div div p b")[0].text
        next if (judge_name == ", ")
        judge_name = judge_name.slice(0..judge_name.index(",")-1)

        judge_court = page.css("form#Form1 div div div p span")[0].text
        judge_court = judge_court.slice(0..judge_court.index(",")-1)
        year = "#{data_year}".to_i

        judge = Judge.find_or_create_by(name: judge_name, court: judge_court)
        admission = Admission.create(judge_id: judge.id, year: year)
        (0..2).each do |table_index|
          category2 = page.css("form#Form1 div div div p.uh2m")[table_index].text
          #puts category2

          #tabulka pre konkretny typ admissionu
          inner_table = page.css("form#Form1 div div div table.tbtxt")[table_index+1]
          #puts inner_table

          if (!inner_table.nil?)
            #riadky v danej tabulke
            rows = inner_table.css("tr")

            @admission_type = 0
            case category2
              when "Nehnuteľný majetok"
                @admission_type = 1
                rows.each do |row|
                  if (row.css("td").text != "")
                    puts "ADMISSION TYPE #{@admission_type}: \n Nehnutelnost: #{row.css("td")[1].text}
                         \n Nadobudnutie: #{row.css("td")[2].text}
                         \n Datum: #{row.css("td")[3].text}
                         \n Zmena: "
                    AdmissionItem.create(admission_id: admission.id, name: row.css("td")[1].text, acquisition_date: row.css("td")[3].text, acquisition_reason: row.css("td")[2].text)
                  end
                end
              when "Hnuteľný majetok"
                @admission_type = 2
                rows.each do |row|
                  if (row.css("td").text != "")
                    puts "ADMISSION TYPE #{@admission_type}: \n Hnutelnost: #{row.css("td")[1].text}
                         \n Nadobudnutie: #{row.css("td")[2].text}
                         \n Datum: #{row.css("td")[3].text}
                         \n Cena: #{row.css("td")[7].text}
                         \n Zmena: "
                    AdmissionItem.create(admission_id: admission.id, name: row.css("td")[1].text, value: row.css("td")[7].text, acquisition_date: row.css("td")[3].text, acquisition_reason: row.css("td")[2].text)
                  end
                end
              when "Majetkové práva, záväzky, hodnoty"
                @admission_type = 3
                rows.each do |row|
                  if (row.css("td").text != "")
                    puts "ADMISSION TYPE #{@admission_type}: \n Popis prava: #{row.css("td")[1].text}
                         \n Nadobudnutie: #{row.css("td")[2].text}
                         \n Datum: #{row.css("td")[3].text}
                         \n Cena: #{row.css("td")[7].text}
                         \n Zmena: #{row.css("td")[8].text}"
                    AdmissionItem.create(admission_id: admission.id, name: row.css("td")[1].text, change: row.css("td")[8].text, value: row.css("td")[7].text, acquisition_date: row.css("td")[3].text, acquisition_reason: row.css("td")[2].text)
                  end
                end
            end
          end
        end

      end
    end

  end

end
