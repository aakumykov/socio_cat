class CreateCardsCategories < ActiveRecord::Migration
  def change
    create_table :cards_categories, id:false do |t|
      t.belongs_to :card, index: true
      t.belongs_to :category, index: true
    end
  end
end
