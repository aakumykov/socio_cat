require 'spec_helper'

describe 'Сессии,' do

	let(:login_title) { 'Вход на сайт' }
	let(:login_button) { 'Войти' }

	shared_examples_for 'страница входа' do
		it { should have_title(full_title(login_title)) }
		it { should have_selector('h1',text:login_title) }
		
		it { should have_selector('label',text:'Электронная почта') }
		it { should have_selector(:xpath,"//input[@id='session_email']") }

		it { should have_selector('label',text:'Пароль') }
		it { should have_selector(:xpath,"//input[@id='session_password']") }
		
		it { should have_selector(:xpath,"//input[@type='submit']") }
		it { should have_selector(:xpath,"//input[@value='#{login_button}']") }
	end

	describe 'страница входа,' do
		before { visit login_path }
		subject { page }

		describe 'строение,' do
			it_should_behave_like 'страница входа'
		end

		describe 'функция,' do
			let(:user_name) {'Пользователь Вася'}
			let(:user_email) {'vasya@user.com'}
			let(:user_password) {'Qwerty123!@#'}
			before {
				@user = FactoryGirl.create(:user, 
					name: user_name,
					email: user_email,
					password: user_password,
					password_confirmation: user_password,
				)
				visit login_path
				fill_in 'Электронная почта', with: user_email
				fill_in 'Пароль', with: user_password
				click_button(login_button)
			}
		end
	end

end
