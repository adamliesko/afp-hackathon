class AddCourtToJudge < ActiveRecord::Migration
  def change
    add_column :judges, :court, :string
  end
end
