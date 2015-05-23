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
  query = I18n.transliterate(query)

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
      "(LOWER(unaccent(judges.name) LIKE ? OR LOWER(unaccent(judges.court)) LIKE ?)"
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
    order("LOWER(judges.name) #{ direction }")
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
        puts "STRANKA http://www.sudnarada.gov.sk/mps/Priznanie#{i}.html"
        (0..4).each do |table_index|
          category2 = page.css("table")[4].css("tr td h3")[table_index].text

          #tabulka pre konkretny typ admissionu
          inner_table = page.css("table")[4].css("tr td table")[table_index]

          if (!inner_table.nil?)

            admission = Admission.create(judge_id: judge.id, year: year)
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
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, change: row.css("div.sbjp")[3].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text)
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
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, value: row.css("div.sbjp")[3].text, change: row.css("div.sbjp")[4].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text)
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
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, value: row.css("div.sbjp")[3].text, change: row.css("div.sbjp")[4].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text)
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
                    AdmissionItem.create(admission_id: admission.id, name: row.css("div.sbjp")[0].text, change: row.css("div.sbjp")[3].text, acquisition_date: row.css("div.sbjp")[2].text, acquisition_reason: row.css("div.sbjp")[1].text)
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

end
