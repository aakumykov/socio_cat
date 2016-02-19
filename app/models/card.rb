class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	has_many :cc_relations
	has_many :categories, through: :cc_relations
	
	before_validation { |m| m.remove_trailing_spaces(:title,:description,:text) }


	enum kind: {
		'черновик' => 'draft',
		'текст' => 'text',
		'картинка' => 'image',
		'аудио' => 'audio',
		'видео' => 'video',
	}

	validates :kind, {
		presence: true,
		# принадлежность к типу enum, чтобы не бросало исключение
	}


	validates :user_id, {
		presence: true,
		format: /\A[0-9]+\z/,
	}


	validates :title, {
		presence: true,
		length: { maximum: 80 }
	}


	validates :description, {
		presence: true,
		length: { 
			minimum: 10,
			maximum: 1024,
		}
	}


	validates :text, {
		length: { 
			minimum: 10,
			maximum: 1024,
		}
	}


	has_attached_file :media
	do_not_validate_attachment_file_type :media

	
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

	def content(type=:any)
		case type
		when :text
			self.text
		when :image
			self.image
		when :audio
			nil
		when :video
			' '
		else
			{
				text: self.text,
				image: self.image,
				audio: nil,
				video: nil,
			}
		end
	end

	def content=(data)
		puts "===== Card.content= =====> kind: #{kind}, data: #{data}"
		case self.kind
		when 'текст'
			self.text = data
		else
			true
		end
	end
end
