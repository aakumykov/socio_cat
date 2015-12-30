class Category < ActiveRecord::Base
	# связи
	# фильтры
	
	# проверки
	validates :name, {
		presence: true,
		length: { minimum: 2, maximum: 20 },
		uniqueness: { case_sensitive: false },
	}

	validates :description, {
		presence: true,
		length: { minimum: 3, maximum: 240 }
	}

	# общие методы
	# частные методы
end
