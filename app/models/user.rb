class User < ActiveRecord::Base

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
end
