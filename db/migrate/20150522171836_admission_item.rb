class AdmissionItem < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.belongs_to :admission, index: true
      t.string :name, index: true
      t.float :value, index: true
      t.string :change, index: true
      t.string :ownership_form , index: true
      t.string :ownership_part , index: true
      t.string :category, index: true
      t.string :acquisition_date, index: true
      t.string :acquisition_reason, index: true
    end

  end
end
