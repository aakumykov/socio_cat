class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	#validates_associated :user
	
	has_and_belongs_to_many :categories
	#validates_associated :categories

	attr_accessor :cat_ids


	before_validation { |m| m.remove_trailing_spaces(:title,:content) }
	before_save :categorize


	validates :title, {
		presence: true,
		length: { maximum: 80 }
	}
	
	validates :content, {
		presence: true,
		length: { maximum: 1000 }
	}

	validates :user_id, {
		presence: true,
		format: /\A[0-9]+\z/,
	}

	private
		def categorize
			if !cat_ids.nil?
				current_cat_ids = Category.where(id:cat_ids).pluck(:id)
				puts "==========> current_cat_ids: #{current_cat_ids}"

				all_cat_ids = cat_ids.concat(current_cat_ids).map!{|i| i.to_i}.uniq!
				puts "==========> all_cat_ids: #{all_cat_ids}"

				new_cats = Category.find(all_cat_ids)
				self.categories.concat(new_cats)
			end
		end
end
