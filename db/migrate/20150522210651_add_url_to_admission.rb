class AddUrlToAdmission < ActiveRecord::Migration
  def change
  	add_column  :admissions, :url, :string
  end
end
