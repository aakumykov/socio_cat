class AddTextToCard < ActiveRecord::Migration
  def change
    add_column :cards, :text, :text
  end
end
