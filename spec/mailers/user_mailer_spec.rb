require 'spec_helper'

describe 'UserMailer,' do
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

	describe 'welcome_message,' do
		before {
			@activation_code = @user.new_activation[:activation_code]
			
			UserMailer.welcome_message({
				user: @user,
				activation_code: @activation_code,
			}).deliver_now!

			@mail = ActionMailer::Base.deliveries.first
		}

		subject { @mail }

		describe 'письмо,' do
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
	end

	pending 'reset_message,' do
		before {
			params = {
				user: @user,
				code: reset_params[:reset_code],
				date: reset_params[:reset_date],
			}
			
			UserMailer.reset_message(params).deliver_now!
		}

		after(:each) {
			ActionMailer::Base.deliveries.clear
		}

		subject { ActionMailer::Base.deliveries.first }

		describe 'сообщение,' do
			it 'отправляется,' do
				ActionMailer::Base.deliveries.count.should eq 1
			end

			# specify{
			# 	puts "=== subject.to ===> #{subject.to}"
			# 	puts "=== subject.from ===> #{subject.from}"
			# 	puts "=== subject.to ===> #{subject.subject}"
			# }

			its(:to) { should eq [@user.email] }
			its(:from) { should eq ['my.sender.personal@yandex.ru'] }
			its(:subject) { should eq 'Восстановление доступа в Соционический каталог' }

			pending 'тело сообщения'
		end
	end
end