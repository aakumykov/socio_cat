require 'spec_helper'

describe 'Сессии,' do

	let(:user) { FactoryGirl.create(:user) }
	let(:login_button) { 'Войти' }

	describe 'страница_входа,' do
		before { visit login_path }
		subject { page }

		describe 'посещение,' do
			it_should_behave_like 'страница_входа'
			it { should have_link('Вход', href:login_path) }
			it { should_not have_link('Выход', href:logout_path) }
		end

		describe 'вход,' do
			describe 'с верными данными,' do
				before {
					fill_in 'Электронная почта', with: user.email
					fill_in 'Пароль', with: user.password
				}

				context 'пользователь не активирован,' do
					before {
						click_button login_button
					}
					it_should_behave_like 'flash-сообщение', 'error', "Учётная запись не подтверждена"
					it_should_behave_like 'страница_входа'
				end

				context 'пользователь активирован,' do
					before {
						user.activate
						click_button login_button
					}
					it { should have_content('Добро пожаловать') }
					it_should_behave_like 'вид_пользователя'
				end
			end

			describe 'с неверными данными,' do
				before { 
					click_button login_button
				}				
				it_should_behave_like 'flash-сообщение', 'error', 'Неверная электронная почта или пароль'
				it_should_behave_like 'страница_входа'
				it_should_behave_like 'вид_гостя'
			end
		end

		describe 'выход,' do
			before { 
				visit login_path
				user.activate
				fill_in 'Электронная почта', with: user.email
				fill_in 'Пароль', with: user.password
				click_button(login_button)

				click_link 'Выход' 
			}
			
			it_should_behave_like 'flash-сообщение', 'success', 'Вы вышли с сайта'
			
			it { should_not have_link('Мой профиль',href: user_path(user)) }
			it { should_not have_link('Пользователи',href: users_path) }
			it { should_not have_link('Выход',href: logout_path) }
		end
	end

end
