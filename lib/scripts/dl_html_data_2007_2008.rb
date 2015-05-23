require 'rubygems'
require 'nokogiri'
require 'open-uri'

(0..1).each do |i| #2873
  begin
    page = Nokogiri::HTML(open("http://wwwold.justice.sk/tma.aspx?sudcaID=#{i}&rok=31.12.07"))
  rescue OpenURI::HTTPError
    puts "404"
  else
    judge_name = page.css("form#Form1 div div div p b")[0].text
    next if (judge_name == ", ")
    judge_name = judge_name.slice(0..judge_name.index(",")-1)
    puts judge_name
    judge_court = page.css("form#Form1 div div div p span")[0].text
    judge_court = judge_court.slice(0..judge_court.index(",")-1)
    puts judge_court
    # pokus = page.css("form#Form1 div div div p.uh2m")[2].text
    # puts pokus
    year = "2008".to_i

    #judge = Judge.find_or_create_by(name: judge_name, court: judge_court)
    (0..2).each do |table_index|
      category2 = page.css("form#Form1 div div div p.uh2m")[table_index].text
      #puts category2

      #tabulka pre konkretny typ admissionu
      inner_table = page.css("form#Form1 div div div table.tbtxt")[table_index+1]
      #puts inner_table

      if (!inner_table.nil?)

        #admission = Admission.create(judge_id: judge.id, year: year)
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
               # AdmissionItem.create(admission_id: admission.id, name: row.css("td")[1].text, acquisition_date: row.css("td")[3].text, acquisition_reason: row.css("td")[2].text)
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
                #AdmissionItem.create(admission_id: admission.id, name: row.css("td")[1].text, value: row.css("div.sbjp")[7].text, acquisition_date: row.css("div.sbjp")[3].text, acquisition_reason: row.css("div.sbjp")[2].text)
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
                #AdmissionItem.create(admission_id: admission.id, name: row.css("td")[1].text, change: {row.css("td")[8].text},value: row.css("td")[7].text, acquisition_date: row.css("td")[3].text, acquisition_reason: row.css("td")[2].text)
              end
            end
        end
      end
    end

  end
end
