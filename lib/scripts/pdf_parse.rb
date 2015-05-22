require 'pdftohtmlr'
require 'nokogiri'
include PDFToHTMLR
file = PdfFilePath.new("/Users/Adam/afp/pdfs/462.pdf")
string = file.convert
doc = file.convert_to_document()
puts string
puts doc