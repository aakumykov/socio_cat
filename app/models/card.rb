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
		'музыка' => 'audio',
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


	validates :title,
		presence: true,
		length: { maximum: 80 }


	validates :description,
		presence: true,
		length: {minimum: 10,maximum: 1024}


	validates :text,
		presence: true,
		length: {minimum: 10,maximum: 1024}, 
		if: "'текст'==self.kind"

	
	has_attached_file :image, default_url: 'no_image'
	validates_attachment(:image,
		presence: true,
		content_type: { content_type: /\Aimage\/.*\Z/ },
		size: { in: 0..1.megabytes },
		if: "'картинка'==self.kind"
	)


	has_attached_file :audio, default_url: 'no_audio'
	validates_attachment(:audio,
		presence: true,
		content_type: { content_type: /\audio\/.*\Z/ },
		size: { in: 0..16.megabytes },
		if: "'музыка'==self.kind"
	)


	has_attached_file :video, default_url: 'no_video'
	validates_attachment(:video,
		presence: true,
		content_type: { content_type: /\video\/.*\Z/ },
		size: { in: 0..50.megabytes },
		if: "'видео'==self.kind"
	)


	# к этому публичному методу не ведёт (и не должен вести) никакой маршрут
	def fill_categories(list)
		self.categories = []
		list.each do |id|
			self.cc_relations.create(category_id: id)
		end
	end

	def content(kind)
		case kind
		when 'текст'
			self.text
		when 'картинка'
			self.image
		when 'музыка'
			self.audio
		when 'видео'
			self.video
		else
			nil
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
