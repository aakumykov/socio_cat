class Matter < ActiveRecord::Base
	has_many :cards, inverse_of: :matter

	validates(:name,
		presence: {message:'не может быть пустым'}
	)
	validates(:name,
		length: {minimum:2, maximum:18, message:'длина от 2 до 16 знаков'},
		if: "!name.blank?"
	)
end
