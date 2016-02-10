require 'spec_helper'

describe 'Почтальон Печкин,' do
	let(:sender_address) { 'my.sender.personal@yandex.ru' }
	
	before(:all) {
		@user = FactoryGirl.create(:user)

		ActionMailer::Base.delivery_method = :test
		ActionMailer::Base.perform_deliveries = true
		ActionMailer::Base.deliveries = []
	}

	after(:each) {
		ActionMailer::Base.deliveries.clear
	}

	describe 'письмо приветствия,' do
		before {
			@activation_code = @user.new_activation[:activation_code]
			
			UserMailer.welcome_message({
				user: @user,
				activation_code: @activation_code,
			}).deliver_now!

			@mail = ActionMailer::Base.deliveries.first
		}

		subject { @mail }

		it 'отправляется,' do
			ActionMailer::Base.deliveries.count.should eq 1
		end

		its(:to) { should eq [@user.email] }
		its(:from) { should eq [sender_address] }
		its(:subject) { should eq 'Добро пожаловать в соционический каталог' }

		specify{
			expect(@mail.body).to have_content(@user.name)
			expect(@mail.body).to have_xpath("//a[@href='#{activation_response_url(@activation_code)}']")
			expect(@mail.body).to have_xpath("//a[@href='#{root_url}']")
		}
	end

	describe 'письмо активации,' do
		before {
			@activation_code = @user.new_activation[:activation_code]
			
			UserMailer.welcome_message({
				user: @user,
				activation_code: @activation_code,
			}).deliver_now!

			@mail = ActionMailer::Base.deliveries.first
		}

		subject { @mail }

		it 'отправляется,' do
			ActionMailer::Base.deliveries.count.should eq 1
		end

		its(:to) { should eq [@user.email] }
		its(:from) { should eq [sender_address] }
		its(:subject) { should eq 'Активация учётной записи на сайте Соционического каталога' }

		specify{
			expect(@mail.body).to have_content(@user.name)
			expect(@mail.body).to have_xpath("//a[@href='#{activation_response_url(@activation_code)}']")
			expect(@mail.body).to have_xpath("//a[@href='#{root_url}']")
		}
	end

	describe 'письмо сброса пароля,' do
		before {
			reset_params = @user.reset_password
			@reset_code = reset_params[:reset_code]
			@reset_date = reset_params[:date]
			
			UserMailer.reset_message({
				user: @user,
				reset_code: @reset_code,
				reset_date: @reset_date,
			}).deliver_now!

			@mail = ActionMailer::Base.deliveries.first
		}

		subject { @mail }

		it 'отправляется,' do
			ActionMailer::Base.deliveries.count.should eq 1
		end

		its(:to) { should eq [@user.email] }
		its(:from) { should eq [sender_address] }
		its(:subject) { should eq 'Восстановление доступа в Соционический каталог' }

		specify{
			expect(@mail.body).to have_content(@user.name)
			expect(@mail.body).to have_xpath("//a[@href='#{url_for_password_reset(reset_code:@reset_code, mode:'url')}']")
			expect(@mail.body).to have_xpath("//a[@href='#{root_url}']")
		}
	end
end