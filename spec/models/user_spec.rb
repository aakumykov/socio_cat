require 'spec_helper'

describe 'User,' do
	before(:each) { 
		@user = User.new(
			name: 'Человече Разумный',
			email: 'homo@sapiens.it',
			#password: '0чень_сЛо#нЫй-пар0ль',
			#password_confirmation: '0чень_сЛо#нЫй-пар0ль',
			password: 'Qwerty123$%^',
			password_confirmation: 'Qwerty123$%^',
		)
	}
	subject { @user }
	
	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }

	it { should be_valid }

	describe 'с некорректными данными,' do
		describe 'отсутствует имя,' do
			before { @user.name = ' ' }
			it { should_not be_valid }
		end
		describe 'отсутствует электронная почта,' do
			before { @user.email = ' ' }
			it { should_not be_valid }
		end
		describe 'имя, длинное с лишком,' do
			before { @user.name = 'А'*100 }
			it { should_not be_valid }
		end
		describe 'кривая электронная почта,' do
			addresses = %w[
				user@foo,com 
				user_at_foo.org 
				example.user@foo. 
				foo@bar_baz.com 
				foo@bar+baz.com
				foo@bar..com
			]
			addresses.each do |bad_email|
				before(:each) { @user.email = bad_email }
				it { should_not be_valid }
			end
		end
		describe 'отсутствует пароль,' do
			before { @user.password = @user.password_confirmation = ' ' }
			it { should_not be_valid }
		end
		describe 'разные пароль и его подтверждение,' do
			before { 
				@user.password = '1'*10
				@user.password_confirmation = '2'*10
			}
			it { should_not be_valid }
		end
		describe 'пароль короткий с лишком,' do
			before { @user.password = '1' }
			it { should_not be_valid }
		end
		describe 'пароль с лишком длинный,' do
			before { @user.password = 'k'*1000 }
			it { should_not be_valid }
		end
		describe 'пароль недостаточно сложный,' do
			specify {
				list = %w[
					qwertyqwerty
					qwerty123
					123456789
					1234%^&*9
					Qwerty123
				]
				list.each do |simple_pass|
					@user.password = simple_pass
					expect(@user).not_to be_valid
				end
			}
		end
	end

	describe 'повторяющиеся данные,' do
		describe 'имя,' do
			before {
				user2 = @user.dup
				user2.email = SecureRandom.uuid.gsub('-','') + '@example.org'
				user2.name = @user.name.upcase
				user2.save!
			}
			it { should_not be_valid }
		end
		describe 'электронка,' do
			before {
				user2 = @user.dup
				user2.name = @user.name + '123'
				user2.email = @user.email.upcase
				user2.save!
			}
			it { should_not be_valid }
		end
	end

	describe 'перевод почты в нижний регистр,' do
		let(:email) { 'address@exampe.com' }
		before {
			@user.email = email.upcase
			@user.save!
		}
		specify { expect(@user.reload.email).to eq email }
	end

	describe 'метод  User.authenticate(),' do
		pending 'в верным паролем,' do

		end
		pending 'с неверным паролем,' do

		end
	end
end