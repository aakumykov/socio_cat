class CreateCcRelations < ActiveRecord::Migration
  def change
    create_table :cc_relations do |t|
      t.integer :category_id
      t.integer :card_id

      t.timestamps
    end

	add_index :cc_relations, :category_id
	add_index :cc_relations, :card_id
	add_index :cc_relations, [:category_id,:card_id], unique:true
  end
end
