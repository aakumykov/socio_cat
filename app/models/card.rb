class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards

	validates :title, {
		presence: true,
		length: { maximum: 80 }
	}
	
	validates :content, {
		presence: true,
		length: { maximum: 1000 }
	}

	
end
