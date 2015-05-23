require '~/RubymineProjects/afp-hackathon/lib/xls_parser/xls_parser.rb'
namespace :parse do
  task xls: :environment do
    Dir.glob("*/*.xlsx") do |filename|
      puts filename
      adm = Admission.new
      adm.parse("/Users/Adam/afp/#{filename}")
    end
  end
end
