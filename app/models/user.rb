class User < ActiveRecord::Base

	class PasswordStrenthValidator < ActiveModel::Validator
		
		def validate(record)
			if password_is_weak?(record.password)
				record.errors.add :base, 'The password is not complex enough.'
			end
		end

		private

			def password_is_weak?(test_string)
				patterns = [
					'[[:lower:]]',
					'[[:upper:]]',
					'[[:digit:]]',
					'[!@#$%^&*()_+=-`~\'"|/\;:.,№? ]'
				]
				format_is_good = true
				patterns.each do |regex|
					test_string.match(regex) or format_is_good = false
				end
				return format_is_good
			end
	end

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

	validates :password, {
		presence: true,
		length: { minimum:8, maximum: 20 },
		confirmation: true,
	}

	validates_with User::PasswordStrenthValidator

	#attr_accessor :password, :password_confirmation
	has_secure_password
end
