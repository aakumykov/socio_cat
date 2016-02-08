class AddActivatedToUser < ActiveRecord::Migration
  def change
    add_column :users, :activated, :boolean, default:true
  end
end
