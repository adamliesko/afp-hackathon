class Judge < ActiveRecord::Base
has_many :admissions

  def parse
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'

    (1..15).each do |i| #2873
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
