class Card < ActiveRecord::Base

	validates :title, {
		presence: true,
		length: { maximum: 80 }
	}
	
	validates :content, {
		presence: true,
		length: { maximum: 1000 }
	}

	
end
