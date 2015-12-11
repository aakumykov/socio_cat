require 'spec_helper'

describe 'Сессии,' do

	let(:login_page_title) { 'Вход на сайт' }
	let(:login_button) { 'Войти' }

	shared_examples_for 'страница входа' do
		it { should have_title(full_title(login_page_title)) }
		it { should have_selector('h1',text:login_page_title) }
		
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

			describe 'провальный вход,' do
				before { click_button login_button }
				it_should_behave_like 'страница входа'
				it { should have_selector('.alert.alert-error') }

				describe 'исчезновение flash-сообщения' do
					before { visit root_path }
					it { should_not have_selector('.alert.alert-error') }
				end
			end

			describe 'успешный вход,' do
				let(:user) { FactoryGirl.create(:user) }
				before {
					visit login_path
					fill_in 'Электронная почта', with: user.email
					fill_in 'Пароль', with: user.password
					click_button(login_button)
				}
				let(:title) { "Страница пользователя" }
				
				it { should have_selector('.alert.alert-success') }
				
				it { should have_link('Мой профиль',href: user_path(user)) }
				it { should have_link('Пользователи',href: users_path) }
				it { should have_link('Выход',href: logout_path) }

				it { should_not have_link('Вход', href:login_path)}

				describe 'и выход,' do
					before { click_link 'Выход' }
					
					it { should have_selector('.alert.alert-success', text: 'Вы вышли с сайта') }
					
					it { should_not have_link('Мой профиль',href: user_path(user)) }
					it { should_not have_link('Пользователи',href: users_path) }
					it { should_not have_link('Выход',href: logout_path) }
				end
			end

			pending 'перенаправление,' do
			end
		end
	end

end
