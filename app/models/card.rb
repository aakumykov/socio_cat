class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	has_many :cc_relations
	has_many :categories, through: :cc_relations

	enum kind: {
		'черновик' => 'draft',
		'текст' => 'text',
		'картинка' => 'picture',
		'аудио' => 'audio',
		'видео' => 'video',
	}

	before_validation { |m| m.remove_trailing_spaces(:title,:content) }

	validates :user_id, {
		presence: true,
		format: /\A[0-9]+\z/,
	}

	validates :title, {
		presence: true,
		length: { maximum: 80 }
	}
	
	validates :content, {
		presence: true,
		length: { 
			minimum: 50,
			maximum: 1000,
		}
	}

	validates :description, {
		presence: true,
		length: { 
			minimum: 10,
			maximum: 1024,
		}
	}

	validates :kind, {
		presence: true
	}

	# к этому публичному методу не ведёт (и не должен вести) никакой маршрут
	def fill_categories(list)
		self.categories = []
		list.each do |id|
			self.cc_relations.create(category_id: id)
		end
	end
end
