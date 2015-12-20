require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:create_button) { 'Создать' }
	let(:edit_button) { 'Изменить' }
	let(:delete_button) { 'Удалить' }

	let(:test_password) { 'Qwerty123!@#' }

	subject { page }


	shared_examples_for 'появление flash-сообщения' do |mode,text=''|
		if text.blank?
			it { should have_selector("div.alert.alert-#{mode}") }
		else
			it { should have_selector("div.alert.alert-#{mode}", text:text) }
		end
	end

	shared_examples_for 'исчезновение flash-сообщения' do |mode|
		before { visit root_path }
		it { should_not have_selector("div.alert.alert-#{mode}") }
	end

	shared_examples_for 'страница с названием' do
		it { should have_title( full_title(title) ) }
		it { should have_selector('h1',text:heading) }
	end

	shared_examples_for 'главная страница' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Соционический каталог' }
			let(:heading) { 'Добро пожаловать' }
		end
	end

	shared_examples_for 'страница входа' do
		it_should_behave_like 'страница с названием' do
			let(:title) {'Вход на сайт'}
			let(:heading) {'Вход на сайт'}
		end
		it { should have_selector(:xpath,"//input[@type='submit']")}
		it { should have_selector(:xpath,"//input[@value='Войти']")}
	end

	shared_examples_for 'требование входа' do
		it_should_behave_like 'страница входа'
		it_should_behave_like 'появление flash-сообщения', 'notice', 'Сначала войдите на сайт'
	end

	shared_examples_for 'страница пользователя' do
		it_should_behave_like 'страница с названием' do
			let(:title) { "Страница пользователя «#{the_user.name}»" }
			let(:heading) { "Страница пользователя «#{the_user.name}»" }
		end
		
		it { should have_content('Имя:') }
		it { should have_content(the_user.name) }
		
		it { should have_content('Электронная почта:') }
		it { should have_content(the_user.email) }
	end

	shared_examples_for 'страница редактирования' do
		it_should_behave_like 'страница с названием' do
			let(:title) { "Редактирование пользователя «#{the_user.name}»" }
			let(:heading) { "Редактирование пользователя «#{the_user.name}»" }
		end
		it_should_behave_like 'форма редактирования'
	end

	shared_examples_for 'страница регистрации' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Регистрация пользователя' }
			let(:heading) { 'Регистрация пользователя' }
		end
		it_should_behave_like 'форма редактирования'
	end

	shared_examples_for 'форма редактирования' do
		it { should have_selector('label',text:'Имя') }
		it { should have_selector(:xpath, "//input[@name='user[name]']") }

		it { should have_selector('label', text:'Электронная почта') }
		it { should have_selector(:xpath, "//input[@name='user[email]']") }

		it { should have_selector('label', text:'Пароль') }
		it { should have_selector(:xpath, "//input[@name='user[password]']") }

		it { should have_selector('label', text:'Подтверждение пароля') }
		it { should have_selector(:xpath, "//input[@name='user[password_confirmation]']") }

		it { should have_link('Отмена') }
	end




	describe 'предфильтры,' do
		pending 'Один тест на группу! Следи за правильным включением предфильтров!'

		let!(:admin) { FactoryGirl.create(:admin) }
		let!(:user) { FactoryGirl.create(:user) }
		let!(:other_user) { FactoryGirl.create(:user) }
		let(:wrong_id) { User.maximum(:id)+1 }

		describe 'not_signed_in_users(),' do
			# должен отказывать вошедшим

			context 'вошедший пользователь,' do
				before {
					sign_in user
					visit register_path
				}
				it_should_behave_like 'появление flash-сообщения', 'error', 'Вы уже зарегистрированы'
				it_should_behave_like 'страница пользователя' do
					let(:the_user) { user }
				end
			end

			context 'невошедший пользователь,' do
				before { visit register_path }
				it_should_behave_like 'страница регистрации'
			end
		end

		describe 'signed_in_users(),' do
			# должен отказывать вошедшим

			context 'невошедший пользователь,' do
				before { visit user_path(user) }
				it_should_behave_like 'требование входа'
			end

			context 'вошедший пользователь,' do
				before { 
					sign_in user
					visit user_path(user) 
				}
				it_should_behave_like 'страница пользователя' do
					let(:the_user) { user }
				end
			end
		end

		describe 'editor_users(),' do
			# должен отказывать всем кроме владельца и админа

			context 'не редактор,' do
				before { 
					sign_in other_user
					visit edit_user_path(user)
				}
				it_should_behave_like 'появление flash-сообщения', 'error', 'Нельзя редактировать другого пользователя'
				it_should_behave_like 'страница пользователя' do
					let(:the_user) { user }
				end
			end

			context 'владелец,' do
				before { 
					sign_in user
					visit edit_user_path(user)
				}
				it_should_behave_like 'страница редактирования' do
					let(:the_user) { user }
				end
			end

			context 'администратор,' do
				before { 
					sign_in admin 
					visit edit_user_path(user)
				}
				it_should_behave_like 'страница редактирования' do
					let(:the_user) { user }
				end
			end
		end

		describe 'admin_users(),' do
			# должен отказывать всем загеристрированным кроме админа
			# (незарегистрированных отшивает другой фильтр)

			describe 'не админ,' do
				before { sign_in other_user, no_capybara: true }
				specify{ expect{ delete user_path(user) }.not_to change(User,:count) }
			end			

			describe 'админ,' do
				before { sign_in admin, no_capybara: true }
				specify{ expect{ delete user_path(user) }.to change(User,:count).by(-1) }
			end
		end

		describe 'reject_nil_target(),' do
			# отклоняет действия над несуществующим пользователем

			before { sign_in user  }

			context 'объекта не существует' do
				before { visit user_path(wrong_id) }
				it_should_behave_like 'появление flash-сообщения', 'error', 'Несуществующий объект'
				it_should_behave_like 'главная страница'
			end

			context 'объект существует' do
				before { visit user_path(user) }
				it_should_behave_like 'страница пользователя' do
					let(:the_user) { user }
				end
			end
		end
	end

	pending 'регистрация пользователя,'

end
