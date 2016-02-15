class AddKindToCard < ActiveRecord::Migration
  def change
    add_column :cards, :kind, :enum, default: 'draft'
  end
end
