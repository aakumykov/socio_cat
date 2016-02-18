class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	has_many :cc_relations
	has_many :categories, through: :cc_relations
	
	before_validation { |m| m.remove_trailing_spaces(:title,:description,:text) }


	enum kind: {
		'черновик' => 'draft',
		'текст' => 'text',
		'картинка' => 'picture',
		'аудио' => 'audio',
		'видео' => 'video',
	}

	validates :kind, {
		presence: true
	}


	validates :user_id, {
		presence: true,
		format: /\A[0-9]+\z/,
	}


	validates :title, {
		presence: true,
		length: { maximum: 80 }
	}

	
	validates :text, {
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

	
	has_attached_file :image

	validates_attachment(:image,
		content_type: { content_type: /\Aimage\/.*\Z/ },
		size: { in: 0..1.megabytes }
	)


	# has_attached_file :audio

	# validates_attachment(:audio,
	# 	content_type: { content_type: /\audio\/.*\Z/ },
	# 	size: { in: 0..16.megabytes }
	# )


	# has_attached_file :video

	# validates_attachment(:video,
	# 	content_type: { content_type: /\video\/.*\Z/ },
	# 	size: { in: 0..50.megabytes }
	# )


	# к этому публичному методу не ведёт (и не должен вести) никакой маршрут
	def fill_categories(list)
		self.categories = []
		list.each do |id|
			self.cc_relations.create(category_id: id)
		end
	end


	def get_content(type)
		case type
		when :text
			self.text
		when :image
			self.image
		when :audio
			self.audio
		when :video
			self.video
		else
			raise "Неизвестный тип '#{type}'"
			nil
		end
	end

	def set_content(type,value)
		#if self.kind.
	end
end
