class CreateAdmission < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.belongs_to :judge, index: true

      t.integer :year, index: true
      t.boolean :proclamation1, index: true
      t.boolean :proclamation2, index: true
      t.boolean :proclamation3, index: true
      t.boolean :proclamation4, index: true
      t.boolean :proclamation5, index: true
      t.boolean :proclamation6, index: true
    end
  end
end
