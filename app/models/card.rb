class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	#validates_associated :user
	
	has_and_belongs_to_many :categories
	#validates_associated :categories

	attr_accessor :cat_ids
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
				new_cats = Category.find(cat_ids)
				self.categories.concat(new_cats).uniq!
			end
		end
end
