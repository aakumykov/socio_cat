require 'spec_helper'

describe 'Сессии,' do
	describe 'страница входа,' do
		before { visit login_path }
		subject { page }

		let(:login_title) { 'Вход на сайт' }
		let(:login_button) { 'Войти' }

		describe 'вид,' do
			it { should have_title(full_title(login_title)) }
			it { should have_selector('h1',text:login_title) }
			
			it { should have_selector('label',text:'Электронная почта') }
			it { should have_selector(:xpath,"//input[@id='session_email']") }

			it { should have_selector('label',text:'Пароль') }
			it { should have_selector(:xpath,"//input[@id='session_password']") }
			
			it { should have_selector(:xpath,"//input[@type='submit']") }
			it { should have_selector(:xpath,"//input[@value='Войти']") }
		end
	end

end
