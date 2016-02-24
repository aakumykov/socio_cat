class AddAttachmentVideoToCards < ActiveRecord::Migration
  def self.up
    change_table :cards do |t|
      t.attachment :video
    end
  end

  def self.down
    remove_attachment :cards, :video
  end
end
