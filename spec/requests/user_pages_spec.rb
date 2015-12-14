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

	shared_examples_for 'страница пользователя' do
		let(:title) { "Страница пользователя" }
		it { should have_title(full_title(title)) }
		it { should have_selector('h1',text:title) }
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
						it_should_behave_like 'страница пользователя'
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
				@user1 = FactoryGirl.create(:user)
				@user2 = FactoryGirl.create(:user)
				
				sign_in @user1
				visit users_path
			}
			it { should have_title(full_title('Пользователи')) }
			it { should have_selector('h1', text: 'Пользователи') }
			
			it { should have_link(@user1.name, href: user_path(@user1)) }
			it { should have_link(@user2.name, href: user_path(@user2)) }
		end
	end

	describe 'просмотр,' do
		before { @user = FactoryGirl.create(:user) }
		
		describe 'НЕзарегистрированныМ,' do
			before { visit user_path(@user) }
			it_should_behave_like 'требование входа'
		end

		describe 'зарегистрированным,' do
			before { 
				sign_in @user
				visit user_path(@user)
			}

			it_should_behave_like 'страница пользователя'
			
			it { should have_content('Имя:') }
			it { should have_content('Электронная почта:') }
			it { should have_content(@user.name) }
			it { should have_content(@user.email) }

			it { should have_link('Редактировать',href:edit_user_path(@user)) }

			describe 'несуществующего пользователя' do
				before { 
					bad_id = User.maximum(:id)+1 
					visit user_path(bad_id)
				}
				it_should_behave_like 'страница с названием', title:'Пользователи'
			end
		end
	end

	describe 'www-редактирование,' do
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
			before { visit edit_user_path(user) }
			it_should_behave_like 'требование входа'
		end
		
		describe 'зарегистрированным,' do
			before { sign_in user }

			describe 'чужой,' do
				before { visit edit_user_path(other_user) }
				it_should_behave_like 'появление flash-сообщения', 'error', 'Нельзя редактировать другого пользователя'
				it_should_behave_like 'страница пользователя'
			end

			describe 'своей,' do
				describe 'посещение,' do
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
						it_should_behave_like 'страница пользователя'
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
		end
	end

	# describe 'редактирование,' do
		
	# 	pending 'для зарегистрированных'
	# 	pending 'для себя самого'
		
	# 	describe 'отображение,' do
	# 		let(:title) { 'Редактирование пользователя' }
	# 		let(:user) { FactoryGirl.create(:user) }
			
	# 		before { visit edit_user_path(user) }

	# 		it { should have_title(full_title(title)) }
	# 		it { should have_selector('h1',text:title) }
	# 		it_should_behave_like 'форма редактирования'
	# 	end

	# 	describe 'работа,' do
	# 		let(:title) { 'Редактирование пользователя' }

	# 		describe 'с неверными данными,' do
	# 			let(:title) { 'Редактирование пользователя' }
	# 			let(:user) { FactoryGirl.create(:user) }
				
	# 			before {
	# 				visit edit_user_path(user)
	# 				  fill_in 'Имя', with:' '
	# 				  fill_in 'Электронная почта', with:' '
	# 				  fill_in 'Пароль', with:' '
	# 				  fill_in 'Подтверждение пароля', with:' '
	# 				click_button submit_button_edit
	# 			}
				
	# 			it { should have_selector('.alert.alert-error') }
	# 			it { should have_title(title) }
	# 			it { should have_selector('h1',text:title) }
				
	# 			specify { expect(user.reload.name).to eq user.name }
	# 			specify { expect(user.reload.email).to eq user.email }
				
	# 			it_should_behave_like 'исчезновение flash-сообщения', 'error'
	# 		end

	# 		describe 'с верными данными,' do
	# 			let(:user) { FactoryGirl.create(:user) }
	# 			let(:new_user) { FactoryGirl.create(:user) }
				
	# 			before {
	# 				visit edit_user_path(user)
	# 				  fill_in 'Имя', with: new_user.name
	# 				  fill_in 'Электронная почта', with: new_user.email
	# 				  fill_in 'Пароль', with: new_user.password
	# 				  fill_in 'Подтверждение пароля', with: new_user.password
	# 			}

	# 			describe 'c уникальными данными,' do
	# 				before {
	# 					new_user.destroy
	# 					click_button 'Изменить'
	# 				}
				
	# 				specify { expect(user.reload.name).to eq new_user.name }
	# 				specify { expect(user.reload.email).to eq new_user.email }
					
	# 				it_should_behave_like 'страница пользователя'
	# 				it_should_behave_like 'появление flash-сообщения', 'success'
	# 				it_should_behave_like 'исчезновение flash-сообщения', 'success'
	# 			end

	# 			describe 'с занятыми данными,' do
	# 				before { click_button 'Изменить' }
				
	# 				specify { expect(user.reload.name).not_to eq new_user.name }
	# 				specify { expect(user.reload.email).not_to eq new_user.email }
					
	# 				it_should_behave_like 'форма редактирования'
	# 				it_should_behave_like 'появление flash-сообщения', 'error'
	# 				it_should_behave_like 'исчезновение flash-сообщения', 'error'
	# 			end
	# 		end
	# 	end
	# end

	describe 'прямой доступ к контроллеру Users,' do

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

		describe 'POST to #create,' do
			describe 'зарегистрированным пользователем,' do
				before { sign_in user, no_capybara: true }
				specify { expect{ post users_path, user_params }.not_to change(User,:count) }
			end
		end

		describe 'PATCH to #update,' do

			describe 'НЕзарегистрированным пользователем,' do
				before { patch user_path(other_user), user_params }
				specify { expect(other_user.reload.name).not_to eq user_params[:user][:name] }
				#specify { expect(response).to redirect_to(root_url) }
			end
			
			describe 'зарегистрированным пользователем,' do
				before{ sign_in user, no_capybara: true }
				describe 'чужой записи' do
					before { patch user_path(other_user), user_params }
					specify { expect(other_user.reload.name).not_to eq user_params[:user][:name] }
					#specify { expect(response).to redirect_to(root_url) }
				end
			end
		end

		pending 'DELETE to #destroy,' do
			describe 'НЕзарегистрированным пользователем,' do
				specify { expect{ delete user_path(user)}.not_to change(User,:count) }
				specify { expect{ delete user_path(other_user)}.not_to change(User,:count) }
			end
			describe 'зарегистрированным пользователем,' do
				before{ sign_in user, no_capybara: true }
				specify { expect{ delete user_path(user)}.not_to change(User,:count) }
				specify { expect{ delete user_path(other_user)}.not_to change(User,:count) }
			end
		end

	end
end
