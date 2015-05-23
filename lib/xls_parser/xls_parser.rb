require 'roo'

class XlsParser
	PARTS = {'estate' => 'Zoznam nehnuteľností','chattel' => 'Hnuteľné veci','property_rights' => 'Majetkové práva','income' =>'Príjem z výkonu funkcie sudcu','monetary_obligation' => 'Peňažné záväzky',
	'chattel_and_property_rights'=> 'Súbor hnuteľných vecí a majetkových práv'}



def parse filename
		xlsx = Roo::Spreadsheet.open(filename)
	sheet = xlsx.sheet(0)
	(sheet.first_row..sheet.last_row).each do |i|
		row = sheet.row(i)
		break if row.include?("Vyhlásenia")
	  	if row.empty? || row.include?('Dátum nadobudnutia')
	    	category = nil
	    	next
	  	end
		if i == 1
			@judge = Judge.find_or_create_by(name: row.first.strip)
		elsif i == 3
			year = row.first.scan(/\d+/).first 
			@admission = Addmission.create(judge: @judge, year: year)
	  	else
	    category =  PARTS.select{ |k,v| row.include?(v)}.first[0]
	    create_admission_item sheet, i, categorz
	  	end
	end
end

private

	def create_admission_item sheet, row_idx, category
		name = cell(row_idx,1).strip
		reason = cell(row_idx,2).strip
		date = cell(row_idx,3).strip
		value = cell(row_idx,4).include?("€") ? cell(row_idx,4).strip.gsub(/[[:space:]]/,'').scan(/\d+/).first.to_i : -1
		form = cell(row_idx,5).strip
		part = cell(row_idx,6).strip.empty ? 1 : cell(row_idx,5).strip
		change = cell(row_idx,7).strip
		AdmissionItem.create(admission: @admission, name:name, value: value, change: change,
			acquisition_reason: reason, acquisition_date: date, ownership_part:part, ownership_form: form, category: category )
	end
end