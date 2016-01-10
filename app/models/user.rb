class User < ActiveRecord::Base

	has_many :cards, inverse_of: :user

	before_validation :rts
	before_create :create_remember_token
	before_save { email.downcase! }

	validates :name, { 
		presence: true,
		uniqueness: { case_sensitive: false },
		length: { maximum:20 },
	}

	VALID_EMAIL_REGEX = /\A([a-z0-9+_]+[.-]?)*[a-z0-9]+@([a-z0-9]+[.-]?)*[a-z0-9]+\.[a-z]+\z/i
	validates :email, { 
		presence: true,
		uniqueness: { case_sensitive: false },
		format: { with: VALID_EMAIL_REGEX },
	}

	has_secure_password

	validates :password, {
		length: { minimum:8, maximum: 20 },
		password_strenth: true,
	}


	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private
		def create_remember_token
			self.remember_token = User.encrypt( User.new_remember_token )
		end
end
