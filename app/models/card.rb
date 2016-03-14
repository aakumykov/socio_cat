class Card < ActiveRecord::Base

	belongs_to :matter, inverse_of: :cards
	 validates_associated :matter
	belongs_to :user, inverse_of: :cards
	has_many :cc_relations
	has_many :categories, through: :cc_relations
	

	attr_accessor :new_matter_name

	enum kind: {
		'черновик' => 'draft',
		'текст' => 'text',
		'картинка' => 'image',
		'музыка' => 'audio',
		'видео' => 'video',
	}


	before_validation { |m|
		m.remove_trailing_spaces(:title,:description,:text) 
		#puts "===== before_validation =====> #{self.kind}"
	}

	validates(:matter_id,
		numericality: true,
	)

	validates(:new_matter_name,
		#presence: true,
		#length: {minimum:2, maximum:18}
		presence: {message:'не может быть пустым'},
		length: {minimum:2, maximum:18, message:'длина от 2 до 16 знаков'}
	)

	validates :kind, {
		presence: {message:'не может быть пустым'},
		# принадлежность к перечисляемому типу!
	}

	validates :user_id, {
		presence: {message:'не может быть пустым'},
		format: /\A[0-9]+\z/,
	}

	validates :title,
		presence: {message:'не может быть пустым'},
		length: {minimun:3, maximum: 80}

	validates(:description,
		presence: {message: 'не может быть пустым'},
		length: {minimum: 10,maximum: 1024,message: 'от 10 до 1024 знаков'},
	)


	attr_accessor :new_category


	validates(:text,
		presence: {message:'не может быть пустым'},
		length: {minimum: 10,maximum: 1024}, 
		if: "'текст'==self.kind"
	)
	
	has_attached_file :image, styles: {medium:'300x300>', thumb:'100x100>'}, default_url: 'no_image'
	validates_attachment(:image,
		presence: {message:'не может быть пустым'},
		content_type: { content_type: /\Aimage\/.*\Z/ },
		size: { in: 0..1.megabytes },
		if: "'картинка'==self.kind"
	)


	has_attached_file :audio, default_url: 'no_audio'
	validates_attachment(:audio,
		presence: {message:'не может быть пустым'},
		content_type: { content_type: /\audio\/.*\Z/ },
		size: { in: 0..16.megabytes },
		if: "'музыка'==self.kind"
	)


	has_attached_file :video, default_url: 'no_video'
	validates_attachment(:video,
		presence: {message:'не может быть пустым'},
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

	def kind?(name)
		name = name.to_s
		name==Card.kinds[self.kind] || name==self.kind
	end
end
