class AddNewPassDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :new_pass_date, :datetime
  end
end
