class AddInPassResetToUser < ActiveRecord::Migration
  def change
    add_column :users, :in_pass_reset, :boolean, default:false
  end
end
