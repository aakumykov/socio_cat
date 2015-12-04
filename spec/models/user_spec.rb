require 'spec_helper'

describe 'User,' do
	before(:each) { 
		@user = User.new(
			name: 'Человече Разумный',
			email: 'homo@sapiens.it',
		)
	}
	subject { @user }
	
	it { should respond_to(:name) }
	it { should respond_to(:email) }

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
			@test_user = User.new(
				name:'Пользователь',
				email:email.upcase,
			)
			@test_user.save!
		}
		specify { expect(@test_user.reload.email).to eq email }
	end


end