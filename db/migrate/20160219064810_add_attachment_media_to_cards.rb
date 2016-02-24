class AddAttachmentMediaToCards < ActiveRecord::Migration
  def self.up
    change_table :cards do |t|
      t.attachment :media
    end
  end

  def self.down
    remove_attachment :cards, :media
  end
end
