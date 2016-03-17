class AddKindToCard < ActiveRecord::Migration
  def change
    add_column :cards, :kind, :string, default: 'draft'
  end
end
