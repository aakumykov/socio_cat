class AddPasswordResetFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :in_reset, :boolean, default: false
    add_column :users, :reset_code, :string
    add_column :users, :reset_date, :datetime
  end
end
