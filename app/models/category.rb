class Category < ActiveRecord::Base
# 
# План:
# ) связь "категория --> карточки"
# ) проверка связи "категория --> карточки"
#
# ) связь "категория <-- карточка"
# ) проверка связи "категория <-- карточка"


	# связи
	has_many :cc_relations
	has_many :cards, through: :cc_relations

	# фильтры
	before_validation { |m| m.remove_trailing_spaces(:name,:description) }
	
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
