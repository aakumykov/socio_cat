class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.integer :user_id
      t.string  :kind, default: 'draft'
      t.string  :title
      t.text    :text
      t.text    :description
      t.attachment :image
      t.attachment :audio
      t.attachment :video
      t.attachment :media

      t.timestamps
    end

    add_index :cards, :user_id
  end

  def self.down
    remove_attachment :cards, :image
    remove_attachment :cards, :audio
    remove_attachment :cards, :video
    remove_attachment :cards, :media
  end
end
