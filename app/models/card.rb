class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	has_many :cc_relations
	has_many :categories, through: :cc_relations
	
	before_validation { |m|
		m.remove_trailing_spaces(:title,:description,:text) 
		#puts "===== before_validation =====> #{self.kind}"
	}


	enum kind: {
		'черновик' => 'draft',
		'текст' => 'text',
		'картинка' => 'image',
		'звук' => 'audio',
		'видео' => 'video',
	}

	validates :kind, {
		presence: true,
		# принадлежность к перечисляемому типу!
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
		},
		allow_nil: true,
	}


	has_attached_file :media
	#do_not_validate_attachment_file_type :media
	# validates_attachment(:media,
	# 	presence: true,
	# ), if: Card.kinds.include?(self.kind)
	# validates_attachment(:media, 
	# 	content_type: { content_type: /\Aimage\/.*\Z/ },
	# )
	validates :media, attachment_content_type: { content_type: /\Aimage\/.*\Z/ }, if: "'картинка'==self.kind"
	validates :media, attachment_content_type: { content_type: /\Aaudio\/.*\Z/ }, if: "'звук'==self.kind"
	validates :media, attachment_content_type: { content_type: /\Avideo\/.*\Z/ }, if: "'видео'==self.kind"

	
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
		when [:image,:audio,:video].include?(type)
			self.media
		else
			{
				text: self.text,
				image: self.media,
				audio: nil,
				video: nil,
			}
		end
	end

	def content=(data)
		puts "===== Card.content= =====> kind: #{kind}, data: #{data}"
		case self.kind
		when 'текст'
			self.text = text
		when 'картинка'
			self.image = data[:image]
		else
			true
		end
	end
end
