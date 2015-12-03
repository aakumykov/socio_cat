class User < ActiveRecord::Base
	validates :name, { presence: true,
		#uniqueness: { case_sensitive: false },
		#langth: { maximum:20 },
	}

	validates :email, { presence: true,
		#uniqueness: { case_sensitive: true },
		#format: { with: VALID_EMAIL_REGEX },
	}

end
