class Category < ActiveRecord::Base
	# связи
	# фильтры
	
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
