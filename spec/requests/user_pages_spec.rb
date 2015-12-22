require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:admin) { FactoryGirl.create(:admin) }
	let(:user) { FactoryGirl.create(:user) }
	let(:other_user) { FactoryGirl.create(:user) }
	let(:wrong_id) { User.maximum(:id)+1 }

	# массовка для списка
	let!(:user1) { FactoryGirl.create(:user) }
	let!(:user2) { FactoryGirl.create(:user) }

	let(:register_button) { 'Зарегистрироваться' }
	let(:edit_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
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

	shared_examples_for 'исчезновение flash-сообщения' do
		before { visit root_path }
		it { should_not have_selector("div.alert") }
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
		it { should have_selector(:xpath,"//input[@type='submit' and @value='Войти']")}
	end

	shared_examples_for 'требование входа' do
		it_should_behave_like 'страница входа'
		it_should_behave_like 'появление flash-сообщения', 'notice', 'Сначала войдите на сайт'
	end

	shared_examples_for 'страница пользователя' do |mode|
		it_should_behave_like 'страница с названием' do
			let(:title) { "Страница пользователя «#{the_user.name}»" }
			let(:heading) { "Страница пользователя «#{the_user.name}»" }
		end
		
		it { should have_content('Имя:') }
		it { should have_content(the_user.name) }
		
		it { should have_content('Электронная почта:') }
		it { should have_content(the_user.email) }

		case mode
		when 'владелец' || 'для админа'
			it { should have_link(edit_button, href: edit_user_path(the_user)) }
		when 'админ'
			it { should have_selector(:xpath,"//a[@href='#{user_path(the_user)}' and @data-method='delete' and text()='#{delete_button}']") }
		else
			it { should_not have_link(edit_button) }
			it { should_not have_link(delete_button) }
		end
	end

	shared_examples_for 'страница редактирования' do
		it_should_behave_like 'страница с названием' do
			let(:title) { "Редактирование пользователя «#{the_user.name}»" }
			let(:heading) { "Редактирование пользователя «#{the_user.name}»" }
		end
		it_should_behave_like 'форма редактирования'
		it { should have_selector(:xpath,"//input[@type='submit' and @value='#{save_button}']") }
	end

	shared_examples_for 'список пользователей' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Пользователи' }
			let(:heading) { 'Пользователи' }
		end

		it { should have_link(user1.name, href:user_path(user1.id)) }
		it { should have_link(user2.name, href:user_path(user2.id)) }
	end

	shared_examples_for 'страница регистрации' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Регистрация пользователя' }
			let(:heading) { 'Регистрация пользователя' }
		end
		it_should_behave_like 'форма редактирования'
		it { should have_selector(:xpath,"//input[@type='submit' and @value='#{register_button}']") }
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
		# --------------------------------------------------------------------#
		# Один тест на группу, обрабатываемую предфильтром.
		# Следи за из корректным включением!
		# --------------------------------------------------------------------#

		describe 'not_signed_in_users(),' do
			# должен отказывать вошедшим

			context 'вошедший пользователь,' do
				before {
					sign_in user
					visit register_path
				}
				it_should_behave_like 'появление flash-сообщения', 'error', 'Вы уже зарегистрированы'
				it_should_behave_like 'страница пользователя', 'владелец' do
					let(:the_user) { user }
				end
			end

			context 'невошедший пользователь,' do
				before { visit register_path }
				it_should_behave_like 'страница регистрации'
			end
		end

		describe 'signed_in_users(),' do
			# должен отказывать не вошедшим

			context 'невошедший пользователь,' do
				before { visit user_path(user) }
				it_should_behave_like 'требование входа'
			end

			context 'вошедший пользователь,' do
				before { 
					sign_in user
					visit user_path(user) 
				}
				it_should_behave_like 'страница пользователя', 'владелец' do
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

			before {
				user.save!
				other_user.save!
			}

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
				it_should_behave_like 'страница пользователя', 'владелец' do
					let(:the_user) { user }
				end
			end
		end
	end


	# #new, #create
	describe 'регистрация пользователя,' do
		before { visit register_path }
		it_should_behave_like 'страница регистрации'

		describe 'отправка данных,' do
			context 'верных,' do
				before {
					fill_in 'Имя', with: Faker::Name.first_name
					fill_in 'Электронная почта', with: Faker::Internet.email
					fill_in 'Пароль', with: test_password
					fill_in 'Подтверждение пароля', with: test_password
				}
				specify{ expect{ click_button register_button}.to change(User,:count).by(1) }

				describe 'уведомление об успехе,' do
					before { click_button register_button }
					it_should_behave_like 'появление flash-сообщения', 'success', 'Добро пожаловать'
				end
			end
			context 'неверных,' do
				specify{ expect{ click_button register_button}.not_to change(User,:count) }

				describe 'уведомление об ошибке,' do
					before { click_button register_button }
					it_should_behave_like 'появление flash-сообщения', 'error', 'ОШИБКА. Пользователь не создан'
					it_should_behave_like 'исчезновение flash-сообщения'
				end
			end
		end
	end

	# #index
	describe 'список пользователей,' do
		before { 
			sign_in user
			visit users_path
		}
		it_should_behave_like 'список пользователей'
	end

	# #show, #edit. #update
	describe 'просмотр и редактирование пользователя,' do
		describe 'просмотр,' do
			before { 
				sign_in user
				visit user_path(user) 
			}
			it_should_behave_like 'страница пользователя', 'владелец' do
				let(:the_user) { user }
			end
			
			describe 'редактирование,' do
				before { click_link edit_button }
				
				it_should_behave_like 'страница редактирования' do
					let(:the_user) { user }
				end

				describe 'изменение данных,' do
					describe 'верное,' do
						let(:new_name) { Faker::Name.first_name }
					 	
					 	before {
					 		fill_in 'Имя', with: new_name
					 		fill_in 'Пароль', with: test_password
					 		fill_in 'Подтверждение пароля', with: test_password
					 		click_button save_button
					 	}
					 	
					 	specify{ expect(user.reload.name).to eq new_name }
					 	
					 	it_should_behave_like 'страница пользователя', 'владелец' do
					 		let(:the_user) { User.find_by(id: user.id) }
					 	end
					 end

					 describe 'неверное,' do
					 	before { click_button save_button }
					 	it_should_behave_like 'появление flash-сообщения', 'error', 'Изменения отклонены'
					 	it_should_behave_like 'исчезновение flash-сообщения'
					 	specify{ expect(user.reload.name).to eq user.name }
					 end
				end
			end
		end
	end

	# #destroy
	describe 'удаление пользователя,' do
		before {
			user.save!
			other_user.save!
			sign_in admin
			visit user_path(user)
		}

		describe 'вид страницы,' do
			it_should_behave_like 'страница пользователя', 'админ' do
				let(:the_user) { user }
			end
		end

		describe 'удаление кнопкой,' do
			describe 'уменьшение количества пользователей,' do
				specify{ expect{ click_link delete_button }.to change(User,:count).by(-1) }
			end
			
			describe 'сообщение об успехе,' do
				before { click_link delete_button }
				it_should_behave_like 'появление flash-сообщения', 'success', 'Пользователь'
				it_should_behave_like 'появление flash-сообщения', 'success', 'удалён'
				it_should_behave_like 'список пользователей'
			end
		end
	end

	describe 'удаление админом самого себя,' do
		before { sign_in admin, no_capybara: true }
		
		specify{ expect{ delete user_path(admin) }.not_to change(User,:count) }

		describe 'перенаправление на страницу пользователя (админа),' do
			before { delete user_path(admin) }
			specify{ expect(response).to redirect_to user_path(admin) }
		end
	end

	# итого тест 7 действий

	describe 'запрещённые атрибуты,' do
		let(:user_params) {
			{ user: {
				name: Faker::Name.first_name,
				email: Faker::Internet.email,
				password: test_password,
				password_confirmation: test_password,
				admin: true
			}}
		}
		before { 
			sign_in user, no_capybara: true
			patch user_path(user), user_params
		}
		specify{ expect(user.reload).not_to be_admin }
	end
end
