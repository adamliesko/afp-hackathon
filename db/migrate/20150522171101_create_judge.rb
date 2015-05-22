class CreateJudge < ActiveRecord::Migration
  def change
    create_table :judges do |t|
      t.string :name, index: true
    end
  end
end
