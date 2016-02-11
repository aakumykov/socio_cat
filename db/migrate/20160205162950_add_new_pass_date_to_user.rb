class AddNewPassDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :new_pass_expire_time, :datetime
  end
end
