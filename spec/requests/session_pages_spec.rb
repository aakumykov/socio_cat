require 'spec_helper'

describe 'Сессии,' do

	let(:login_link) { 'Вход' }
	let(:login_button) { 'Войти' }

	describe 'страница входа,' do
		before { visit login_path }
		subject { page }

		describe 'строение,' do
			it_should_behave_like 'страница_входа'
		end

		describe 'функция,' do

			describe 'провальный вход,' do
				before { click_button login_button }
				it_should_behave_like 'страница_входа'
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
				
				it_should_behave_like 'flash-сообщение', 'success', "Добро пожаловать"
				it_should_behave_like 'все_статические_страницы', 'пользователь'

				describe 'и выход,' do
					before { click_link 'Выход' }
					
					it_should_behave_like 'flash-сообщение', 'success', 'Вы вышли с сайта'
					it_should_behave_like 'все_статические_страницы', 'гость'
				end
			end

			pending 'перенаправление,' do
			end
		end
	end
end
