class User < ActiveRecord::Base
	validates :name, { presence: true,
		uniqueness: { case_sensitive: false },
		length: { maximum:20 },
	}

	VALID_EMAIL_REGEX = /\A([a-z0-9+_]+[.-]?)*[a-z0-9]+@([a-z0-9]+[.-]?)*[a-z0-9]+\.[a-z]+\z/i
	validates :email, { presence: true,
		uniqueness: { case_sensitive: true },
		format: { with: VALID_EMAIL_REGEX },
	}

end
