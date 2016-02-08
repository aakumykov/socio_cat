require 'spec_helper'

describe 'Пользователь,' do
	let(:test_password) { '0чень_сЛо#нЫй-пар0ль' }

	before(:each) { 
		@user = User.new(
			name: Faker::Name.first_name,
			email: Faker::Internet.email,
			password: test_password,
			password_confirmation: test_password,
		)
	}
	subject { @user }
	
	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:authenticate) }
	it { should respond_to(:remember_token) }
	it { should respond_to(:admin) }

	it { should respond_to(:activated) } # присутствует
	
	#it { should respond_to(:cards) } # теперь в разделе 'связь с карточками'
	# ПЕРЕНЕСТИ СЮДА!

	# значения по умолчанию
	it { should_not be_admin }
	its(:admin) { should be_false }
	
	it { should_not be_activated } # является (по умолчанию)
	its(:activated) { should be_false }

	# проверки
	it 'модель с корректными данными' do
		should be_valid
	end

	describe 'модель с некорректными данными,' do
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
		describe 'пароль короткий, с лишком,' do
			before { @user.password = @user.password_confirmation = '1' }
			it { should_not be_valid }
		end
		describe 'пароль с лишком длинный,' do
			before { @user.password = @user.password_confirmation = 'k'*1000 }
			it { should_not be_valid }
		end
		describe 'пароль недостаточно сложный,' do
			specify 'модель должна быть некорректной' do
				passwd_list = %w[
					qwertyqwerty
					qwerty123
					123456789
					1234%^&*9
					Qwerty123
					Qwerty!@#
				]
				passwd_list.each do |simple_pass|
					@user.password = @user.password_confirmation = simple_pass
					expect(@user).not_to be_valid
				end
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
	end


	describe 'перевод почты в нижний регистр,' do
		let(:email) { 'address@exampe.com' }
		before {
			@user.email = email.upcase
			@user.save!
		}
		specify { expect(@user.reload.email).to eq email }
	end

	describe 'значение, возвращаемое методом authenticate(),' do
		before { @user.save! }
		let(:user_by_email) { User.find_by(email:@user.email) }
		let(:right_user) { user_by_email.authenticate(@user.password) }
		let(:wrong_user) { user_by_email.authenticate(SecureRandom.uuid) }

		describe 'с верным паролем,' do
			specify { expect(right_user).to eq @user }
		end

		describe 'с неверным паролем,' do
		 	specify { expect(wrong_user).not_to eq @user }
		 	specify { expect(wrong_user).to be_false }
		end
	end

	# Эти свойства приходят не от пользователя,
	# поэтому проверяются не валидациями, а здесь, вручную.
	describe 'непустой remember_token,' do
		before { @user.save }
		its(:remember_token) { should_not be_blank }
	end
	
	describe 'переключение флага администратора,' do
		before { 
			@user.save!
			@user.toggle!(:admin)
		}
		it { should be_admin }
	end

	describe 'метод activate()' do
		describe 'false' do
			before {
				@user.activate(false)
			}
			specify {
				expect(@user).not_to be_activated
			}
		end

		describe 'true' do
			before {
				@user.activate
			}
			specify {
				expect(@user).to be_activated
			}
		end
	end

	describe 'связь с карточками,' do
		let(:user) { FactoryGirl.create(:user) }
		
		let!(:older_card) { user.cards.create(title: Faker::Lorem.word.capitalize, content: Faker::Lorem.paragraph, created_at: 1.month.ago) }
		let!(:newer_card) { user.cards.create(title: Faker::Lorem.word.capitalize, content: Faker::Lorem.paragraph, created_at: 1.hour.ago) }

		subject { user }
		
		it 'должен иметь метод #cards' do
			should respond_to(:cards)
		end

		it 'обладает всеми своими карточками в правильном порядке,' do
			expect(user.cards.to_a).to eq [older_card, newer_card]
		end
		
		describe 'при уничтожении пользователя кардочки должны сохраняться,' do
			before { user.destroy }

			specify{ expect(Card.first).to eq older_card }
			specify{ expect(Card.last).to  eq newer_card }
			
			specify{ expect(Card.first.user).to be_nil }
			specify{ expect(Card.last.user).to be_nil }
		end
	end

	describe 'сброс пароля,' do
		describe 'атрибуты сброса,' do
			it { should respond_to(:in_reset) }
			it { should respond_to(:in_pass_reset) }
			it { should respond_to(:reset_code) }
			it { should respond_to(:reset_date) }
			it { should respond_to(:new_pass_expire_time) }
		end

		describe 'методы сброса,' do
			describe 'reset_password()' do
				let!(:old_reset_flag) { @user.in_reset }
				let!(:old_pass_reset_flag) { @user.in_pass_reset }
				before {
					@user.reset_password
				}
				specify{
					expect(old_reset_flag).to eq false
					expect(old_pass_reset_flag).to eq false

					expect(@user.reload.in_reset).to eq true
					expect(@user.reload.in_pass_reset).to eq true
				}
			end

			describe 'drop_reset_flags(mode)' do
				describe 'link mode,' do
					before {
						@user.reset_password
						@user.drop_reset_flags(:link)
					}
					specify {
						expect(@user.reload.in_reset).to eq false
						expect(@user.reload.in_pass_reset).to eq true
					}
				end

				describe 'full mode,' do
					before {
						@user.reset_password
						@user.drop_reset_flags(:full)
					}
					specify {
						expect(@user.reload.in_reset).to eq false
						expect(@user.reload.in_pass_reset).to eq false
					}
				end
			end
		end
	end

	pending '@user.welcome_message'
end
