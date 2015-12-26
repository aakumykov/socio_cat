class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	#validates_associated :user

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
end
