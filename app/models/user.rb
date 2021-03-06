class User < ActiveRecord::Base

	has_many :cards, inverse_of: :user

	before_validation { |m| m.remove_trailing_spaces(:name,:email) }
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

	# def welcome_message(activation_code)
	# 	UserMailer.welcome_message(self,activation_code).deliver_now!
	# end

	def new_activation
		code = User.new_remember_token
		self.update_attribute(:activated,false)
		self.update_attribute(:activation_code, User.encrypt(code))
		return { activation_code: code }
	end

	def activate(status=true)
		#puts "===== модель: User#activate (before) =====> #{self.activated}"
		self.update_attribute(:activated,status)
		#puts "===== модель: User#activate (after) =====> #{self.activated}"
	end

	def reset_password
		date = Time.now
		reset_code = User.new_remember_token

		self.update_attribute(:reset_date, date)
		self.update_attribute(:reset_code, User.encrypt(reset_code))
		self.update_attribute(:in_reset, true)
		self.update_attribute(:in_pass_reset, true)

		return { date: date, reset_code: reset_code }
	end

	def drop_reset_flags(mode=:full)
		#self.toggle!(:in_reset)
		#self.toggle!(:in_pass_reset)

		case mode
		when :link
			self.update_attribute(:in_reset, false)
		when :full
			self.update_attribute(:in_reset, false)
			self.update_attribute(:in_pass_reset, false)
		end
	end

	private
		def create_remember_token
			self.remember_token = User.encrypt( User.new_remember_token )
		end
end
