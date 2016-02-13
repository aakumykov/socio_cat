class Card < ActiveRecord::Base

	attr_reader :description # временно

	belongs_to :user, inverse_of: :cards

	has_many :cc_relations
	has_many :categories, through: :cc_relations


	before_validation { |m| m.remove_trailing_spaces(:title,:content) }


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

	# к этому публичному методу не ведёт (и не должен вести) никакой маршрут
	def fill_categories(list)
		self.categories = []
		list.each do |id|
			self.cc_relations.create(category_id: id)
		end
	end
end
