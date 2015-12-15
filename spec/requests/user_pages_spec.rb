require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:login_title) { 'Вход на сайт' }
	let(:submit_button_create) { 'Создать' }
	let(:submit_button_edit) { 'Изменить' }

	let(:name_label) { 'Имя' }
	let(:email_label) { 'Электронная почта' }
	let(:password_label) { 'Пароль' }
	let(:password2_label) { 'Подтверждение пароля' }

	#let(:test_name) { 'Проверяльщик Иван' }
	#let(:test_email) { 'test-user@example.com' }
	let(:test_password) { 'Qwerty123!@#' }

	subject { page }

	shared_examples_for 'страница пользователя' do |mode='чужая'|
		let(:title) { 'Страница пользователя' }
		it { should have_title(full_title(title)) }
		it { should have_selector('h1',text:title) }
		if 'своя'==mode
			it { should have_link('Редактировать') }
		elsif
			it { should_not have_link('Редактировать') }
		end
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

	shared_examples_for 'страница входа' do
		it { should have_title( full_title(login_title) ) }
		it { should have_selector('h1',text:login_title) }
		it { should have_selector(:xpath,"//input[@type='submit']")}
		it { should have_selector(:xpath,"//input[@value='Войти']")}
	end

	shared_examples_for 'требование входа' do
		it_should_behave_like 'страница входа'
		it_should_behave_like 'появление flash-сообщения', 'notice', 'Сначала войдите на сайт'
	end

	shared_examples_for 'страница с названием' do |data|
		title = data[:title]
		heading = data[:heading] || title
		it { should have_title( full_title(title) ) }
		it { should have_selector('h1',text:heading) }
	end


	describe 'создание,' do

		describe 'посещение страницы регистрации зарегистрированным пользователем,' do
			before {
				@user = FactoryGirl.create(:user)
				sign_in @user
				visit new_user_path
			}
			it_should_behave_like 'появление flash-сообщения', 'notice', 'Вы уже зарегистрированы'
			it_should_behave_like 'страница с названием', title: 'Страница пользователя'
		end

		describe 'незарегистрированным пользователем,' do
			before { visit new_user_path }

			describe 'отображение формы,' do
				let(:title) { 'Регистрация пользователя' }
				it { should have_title(full_title(title)) }
				it { should have_selector('h1',text:title) }
				it { should have_selector(:xpath, "//input[@value='Создать']") }
				it_should_behave_like 'форма редактирования'
			end

			describe 'работа формы,' do
				
				describe 'с верными данными,' do
					#let(:test_password) { 'ОченьСложныйПароль123$%^' }
					let(:test_password) { 'Qwerty123!@#' }
					let(:test_email) { 'homo@sapiens.me' }
					
					before {
						fill_in 'Имя', with: 'Человек'
						fill_in 'Электронная почта', with: test_email
						fill_in 'Пароль', with: test_password
						fill_in 'Подтверждение пароля', with: test_password
					}
					
					it 'появление пользователя,' do
						expect{ click_button(submit_button_create) }.to change(User, :count).by(1)
					end
					
					describe 'сообщение об успехе,' do
						before { click_button(submit_button_create) }
						it_should_behave_like 'страница пользователя', 'своя'
					end

					describe 'автоматический вход пользователя на сайт,' do
						before { click_button submit_button_create }
						
						let(:user) { User.find_by(email: test_email) }
						
						it { should have_selector('.alert.alert-success', text:'Добро пожаловать на сайт!') }
						it { should have_link('Мой профиль', user_path(user)) }
						it { should have_link('Пользователи', users_path) }
						it { should have_link('Выход', logout_path) }
					end
				end
				
				describe 'с неверными данными,' do
					it 'отклонение нового пользователя,' do
						expect{ click_button(submit_button_create) }.not_to change(User,:count)
					end
					describe 'сообщение об ошибке,' do
						before { click_button(submit_button_create) }
						it_should_behave_like 'появление flash-сообщения', 'error'
					end
					it_should_behave_like 'исчезновение flash-сообщения', 'error'
				end

				describe 'с частично верными данными,' do
					describe 'имя,' do
						before {
							fill_in 'Имя', with: 'Человече'
							click_button(submit_button_create)
						}
						it_should_behave_like 'появление flash-сообщения', 'error'
					end
					describe 'электронная почта,' do
						before {
							fill_in 'Электронная почта', with: 'user@example.we'
							click_button(submit_button_create)
						}
						it_should_behave_like 'появление flash-сообщения', 'error'
					end
				end
			end
		end
	end

	describe 'список,' do
		describe 'для незарегистрированных пользователей,' do
			before { visit users_path }
			it_should_behave_like 'требование входа'
		end
		
		describe 'для зарегистрированных пользователей,' do
			before {
				@user = FactoryGirl.create(:user)
				@other_user = FactoryGirl.create(:user)
				
				sign_in @user
				visit users_path
			}
			it { should have_title(full_title('Пользователи')) }
			it { should have_selector('h1', text: 'Пользователи') }
			
			it { should have_link(@user.name, href: user_path(@user)) }
			it { should have_link(@other_user.name, href: user_path(@other_user)) }

			describe 'выделение активного пользователя,' do
				it { should have_selector(:xpath,"//b//a[@href='#{user_path(@user)}']") }
			end
		end
	end

	describe 'просмотр,' do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		
		describe 'НЕзарегистрированным,' do
			before { visit user_path(user) }
			it_should_behave_like 'требование входа'
		end

		describe 'зарегистрированным,' do
			before { sign_in user }

			describe 'своей страницы,' do
				before { visit user_path(user) }
				it_should_behave_like 'страница пользователя', 'своя'
			end
			
			describe 'чужой страницы,' do
				before { visit user_path(other_user) }
				it_should_behave_like 'страница пользователя', 'чужая'
			end

			describe 'несуществующей страницы' do
				before { 
					bad_id = User.maximum(:id)+1 
					visit user_path(bad_id)
				}
				it_should_behave_like 'появление flash-сообщения', 'error', 'Такой страницы не существует'
				it_should_behave_like 'страница с названием', title:'Пользователи'
			end
		end
	end

	describe 'редактирование,' do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		let(:user_params) {
			{ user: {
				name: user.name,
				email: user.email,
				password: user.password,
				password_confirmation: user.password,
			}}
		}

		describe 'НЕзарегистрированным,' do
			describe 'форма,' do
				before { visit edit_user_path(user) }
				it_should_behave_like 'требование входа'
			end

			describe 'отправка данных,' do
				before { patch user_path(user), user_params }
				specify { expect(response).to redirect_to root_url }
			end
		end
		
		describe 'зарегистрированным,' do
			before { sign_in user }

			describe 'чужой,' do
				describe 'форма,' do
					before { visit edit_user_path(other_user) }
					it_should_behave_like 'появление flash-сообщения', 'error', 'Доступ запрещён'
					it_should_behave_like 'страница пользователя'
				end

				describe 'отправка данных,' do
					before { patch user_path(other_user), user_params }
					specify{ expect(response).to redirect_to root_url }
				end
			end

			describe 'своей,' do
				describe 'форма,' do
					before { visit edit_user_path(user) }
					it_should_behave_like 'форма редактирования'
					describe 'форма редактирования -> страница редактирования'
				end

				describe 'работа,' do
					before { visit edit_user_path(user) }

					describe 'с верными данными,' do
						let(:new_name) { Faker::Name.first_name }
						let(:new_email) { Faker::Internet.email }
						before {
							fill_in name_label, with: new_name
							fill_in email_label, with: new_email
							fill_in password_label, with: user.password
							fill_in password2_label, with: user.password
							click_button submit_button_edit
						}
						it_should_behave_like 'появление flash-сообщения', 'success', 'Изменения приняты'
						it_should_behave_like 'страница пользователя', 'своя'
						specify { expect(user.reload.name).to eq new_name }
						specify { expect(user.reload.email).to eq new_email }
					end

					describe 'c неверными данными,' do
						before { click_button submit_button_edit }
						it_should_behave_like 'появление flash-сообщения', 'error'
						it_should_behave_like 'исчезновение flash-сообщения'
						specify { expect(user.reload.name).to eq user.name }
						specify { expect(user.reload.email).to eq user.email }
					end
				end
			end

			describe 'несуществующей,' do
				let(:wrong_id) { User.maximum(:id)+1 }

				describe 'форма,' do
					before { visit user_path(wrong_id) }
					it_should_behave_like 'появление flash-сообщения', 'error', 'Такой страницы не существует'
					it_should_behave_like 'страница с названием', title:'Пользователи'
				end

				describe 'отправка данных,' do
					before { patch user_path(wrong_id), user_params }
					specify{ expect(response).to redirect_to root_url }
				end
			end
		end
	end

	# describe 'прямое (http) редактирование,' do

	# 	let(:user) { FactoryGirl.create(:user) }
	# 	let(:other_user) { FactoryGirl.create(:user) }
	# 	let(:user_params) {
	# 		{ user: {
	# 			name: Faker::Name.first_name,
	# 			email: Faker::Internet.email,
	# 			password: user.password,
	# 			password_confirmation: user.password,
	# 		}}
	# 	}
	# 	let(:other_user_params) {
	# 		{ user: {
	# 			name: Faker::Name.first_name,
	# 			email: Faker::Internet.email,
	# 			password: other_user.password,
	# 			password_confirmation: other_user.password,
	# 		}}
	# 	}

	# 	describe 'НЕзарегистрированным,' do
	# 		before { patch user_path(user), user_params }
	# 		specify{ expect(user.reload.name).not_to eq user_params[:user][:name] }
	# 		specify{ expect(user.reload.email).not_to eq user_params[:user][:email] }
	# 		#specify{ expect(response).to redirect_to root_url }
	# 	end

	# 	describe 'зарегистрированным,' do
	# 		before { sign_in user, no_capybara: true }

	# 		describe 'своей,' do
	# 			before { patch user_path(user), user_params }
	# 			specify{ expect(user.reload.name).not_to eq user_params[:user][:name] }
	# 			specify{ expect(user.reload.email).not_to eq user_params[:user][:email] }
	# 		end
			
	# 		describe 'чужой,' do
	# 			before { patch user_path(other_user), other_user_params }
	# 			specify{ expect(other_user.reload.name).not_to eq user_params[:user][:name] }
	# 			specify{ expect(other_user.reload.email).not_to eq user_params[:user][:email] }
	# 		end
	# 	end
	# end

	pending 'защищённые параметры,' do
	end
end
