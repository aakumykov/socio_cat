class AddMatterIdToCard < ActiveRecord::Migration
  def change
	  add_column :cards, :matter_id, :integer
  end
end
