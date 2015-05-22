class ClosePerson < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.belongs_to :admission, index: true
      t.string :institution, index: true
      t.string :function, index: true
      t.string :name, index: true
      t.string :title_front
      t.string :title_back
    end
  end
end
