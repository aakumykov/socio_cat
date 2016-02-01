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

		describe 'провальный вход,' do
			before { click_button login_button }
			it_should_behave_like 'страница_входа'
			it_should_behave_like 'flash-сообщение', 'error', 'Неверная электронная почта или пароль'
		end

		describe 'успешный вход,' do
			before {
				visit login_path
				fill_in 'Электронная почта', with: user.email
				fill_in 'Пароль', with: user.password
				click_button(login_button)
			}
			
			it { should have_selector('.alert.alert-success') }
			
			it_should_behave_like 'главная_страница'
			
			it { should have_link('Выход', href:logout_path) }
			it { should_not have_link('Вход', href:login_path) }
		end

		# describe 'выход,' do
		# 	before { click_link 'Выход' }
			
		# 	it { should have_selector('.alert.alert-success', text: 'Вы вышли с сайта') }
			
		# 	it { should_not have_link('Мой профиль',href: user_path(user)) }
		# 	it { should_not have_link('Пользователи',href: users_path) }
		# 	it { should_not have_link('Выход',href: logout_path) }
		# end
	end

end
