class Matter < ActiveRecord::Base
	has_many :cards, reverse_of: :matter
end
