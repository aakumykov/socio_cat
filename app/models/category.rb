class Category < ActiveRecord::Base
# 
# План:
# ) связь "категория --> карточки"
# ) проверка связи "категория --> карточки"
#
# ) связь "категория <-- карточка"
# ) проверка связи "категория <-- карточка"


	# связи
	has_and_belongs_to_many :cards

	# фильтры
	before_validation :remove_trailing_spaces
	
	# проверки
	validates :name, {
		presence: true,
		length: { minimum: 2, maximum: 32 },
		uniqueness: { case_sensitive: false },
	}

	validates :description, {
		presence: true,
		length: { minimum: 3, maximum: 500 }
	}

	# общие методы

	# частные методы
end
