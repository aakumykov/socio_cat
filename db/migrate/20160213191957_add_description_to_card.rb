class AddDescriptionToCard < ActiveRecord::Migration
  def change
    add_column :cards, :description, :text
  end
end
