class Admission < ActiveRecord::Base
has_many :admission_items
belongs_to :judge
PARTS = {'estate' => 'Zoznam nehnuteľností','chattel' => 'Hnuteľné veci','property_rights' => 'Majetkové práva','income' =>'Príjem z výkonu funkcie sudcu','monetary_obligation' => 'Peňažné záväzky',
	'chattel_and_property_rights'=> 'Súbor hnuteľných vecí a majetkových práv', 'benefits' => 'Príjmy a iné pôžitky', 'close_person' => 'Zoznam blízkych osôb'}



def parse filename
		xlsx = Roo::Spreadsheet.open(filename)
	sheet = xlsx.sheet(0)
	category=nil
	(sheet.first_row..sheet.last_row).each do |i|

		row = sheet.row(i).join("")

		 if row.include?("Vyhlásenia")
		 	next
		 	break
		end	
 		res = PARTS.select{ |k,v| row.include?(v)}
 		unless res.empty?
 			category =  res.first[0] 
 			next
 		end

	  	if row.empty? || row.include?('Dátum nadobudnutia') || row.include?('Popis') || row.include?('Príjmy a iné pôžitky') || row.include?('Priezvisko') || row =~ /^[1-9]/
	    	next
	  	end

		if i == 1
			@judge = Judge.find_or_create_by(name: row.strip)
		elsif i == 3
			year = row.scan(/\d+/).first 
			@admission = Admission.create(judge: @judge, year: year, url: "http://mps.sudnarada.gov.sk/data/att/#{filename.scan(/\d+/).first }.pdf")
	  	else
	    create_admission_item sheet, i, category if category
	  	end
	end
end

private

	def create_admission_item sheet, row_idx, category
		if category == 'benefits' 
			name = sheet.cell(row_idx,1).strip if sheet.cell(row_idx,1)
			value = sheet.cell(row_idx,2).include?("€") ? sheet.cell(row_idx,2).strip.gsub(/[[:space:]]/,'').scan(/\d+/).first.to_i : -1  if sheet.cell(row_idx,2)
			AdmissionItem.create(admission: @admission, name:name, value: value, category: category ) if value
		elsif category == 'close_person'
					surname = sheet.cell(row_idx,1).strip if sheet.cell(row_idx,1)
					given_name = sheet.cell(row_idx,2).strip if sheet.cell(row_idx,2)
					title_front = sheet.cell(row_idx,3).strip if sheet.cell(row_idx,3)
					title_back = sheet.cell(row_idx,4).strip if sheet.cell(row_idx,4)
					institution = sheet.cell(row_idx,5).strip if sheet.cell(row_idx,5)
					function= sheet.cell(row_idx,6).strip if sheet.cell(row_idx,6)
			ClosePerson.create(function: function, admission: @admission, name: surname+given_name, institution: institution, title_front: title_front, title_back: title_back ) if surname and institution
		else
		name = sheet.cell(row_idx,1).strip if sheet.cell(row_idx,1)
		reason = sheet.cell(row_idx,2).strip if sheet.cell(row_idx,2)
		date = sheet.cell(row_idx,3).strip if sheet.cell(row_idx,3)
		if sheet.cell(row_idx,4).is_a? String    
			value = sheet.cell(row_idx,4).include?("€") ? sheet.cell(row_idx,4).strip.gsub(/[[:space:]]/,'').scan(/\d+/).first.to_i : -1  if sheet.cell(row_idx,4)
		else
			value  = sheet.cell(row_idx,4)
		end

		form = sheet.cell(row_idx,6).strip if sheet.cell(row_idx,6)
		part = sheet.cell(row_idx,5).empty? ? 1 : sheet.cell(row_idx,5).strip.gsub("," , "\/") if sheet.cell(row_idx,5)
		change = sheet.cell(row_idx,7).strip if sheet.cell(row_idx,7)
		
		AdmissionItem.create(admission: @admission, name:name, value: value, change: change, acquisition_reason: reason, acquisition_date: date, ownership_part:part, ownership_form: form, category: category ) if value
		end
	end

end
