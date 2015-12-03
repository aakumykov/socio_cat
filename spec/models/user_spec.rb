require 'spec_helper'

describe 'User,' do
	before(:each) { 
		# @user = User.new(
		# 	name: 'Человече Разумный',
		# 	email: 'homo@sapiens.it',
		# )
		@user = FactoryGirl.create(:user)
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

	# describe 'коррекция регистра электронной почты,' do
	# 	addresses = %w[
	# 		QWERTY@EXAMPLE.COM
	# 		QWErty@exaMPLE.CoM
	# 		qwerty@EXAMPLE.ORG
	# 	]
	# end

	describe 'повторяющиеся данные,' do
		describe 'имя,' do
			#let(:user1) { FactoryGirl.create(:user) }
			#let(:user2) { FactoryGirl.create(:user) }
			#subject {user2}
			#it { should_not be_valid }
			before {
				#@second_user = FactoryGirl.create(:user)
				second_user = @user.dup
				second_user.save
			}
			it { should_not be_valid }
			#it 'qwerty,' do
				#expect(@second_user).not_to be_valid
			#end
		end
		#describe 'электронка,' do

		#end
	end
end