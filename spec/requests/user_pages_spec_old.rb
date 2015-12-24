require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:create_element) { 'Создать' }
	let(:edit_element) { 'Изменить' }
	let(:delete_element) { 'Удалить' }

	let(:name_label) { 'Имя' }
	let(:email_label) { 'Электронная почта' }
	let(:password_label) { 'Пароль' }
	let(:password2_label) { 'Подтверждение пароля' }

	let(:test_password) { 'Qwerty123!@#' }

	subject { page }


	shared_examples_for 'страница пользователя' do |mode='чужая',admin=false|
		let(:title) { 'Страница пользователя' }
		it { should have_title(full_title(title)) }
		it { should have_selector('h1',text:title) }

		if admin
			if 'чужая'==mode
				it { should have_link('Редактировать') }
				it { should have_link('Удалить') }
			else
				it { should have_link('Редактировать') }
				it { should_not have_link('Удалить') }
			end
		else
			if 'своя'==mode
				it { should have_link('Редактировать') }
				it { should have_link('Удалить') }
			elsif
				it { should_not have_link('Редактировать') }
			end
		end
	end

	shared_examples_for 'зарегистрированный пользователь' do
		# it { should have_link('Мой профиль', user_path(user)) }
		it { should have_link('Мой профиль') }
		it { should have_link('Пользователи', users_path) }
		it { should have_link('Выход', logout_path) }
		it { should_not have_link('Вход', login_path) }
	end

	shared_examples_for 'НЕзарегистрированный пользователь' do
		#it { should_not have_link('Мой профиль', user_path(user)) }
		it { should_not have_link('Мой профиль') }
		it { should_not have_link('Пользователи', users_path) }
		it { should_not have_link('Выход', logout_path) }
		it { should have_link('Вход', login_path) }
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
	
	shared_examples_for 'главная страница' do
		it_should_behave_like 'страница с названием', title:'Соционический каталог', heading:'Добро пожаловать'
	end

	shared_examples_for 'страница входа' do
		it_should_behave_like 'страница с названием', title:'Вход на сайт'
		it { should have_selector(:xpath,"//input[@type='submit']")}
		it { should have_selector(:xpath,"//input[@value='Войти']")}
	end





	describe 'создание,' do

		pending 'user should not be_admin'

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
						expect{ click_button(create_element) }.to change(User, :count).by(1)
					end
					
					describe 'сообщение об успехе,' do
						before { click_button(create_element) }
						it_should_behave_like 'страница пользователя', 'своя'
					end

					describe 'автоматический вход пользователя на сайт,' do
						before { click_button create_element }
						
						let(:user) { User.find_by(email: test_email) }
						
						it { should have_selector('.alert.alert-success', text:'Добро пожаловать на сайт!') }
						it_should_behave_like 'зарегистрированный пользователь'
					end
				end
				
				describe 'с неверными данными,' do
					it 'отклонение нового пользователя,' do
						expect{ click_button(create_element) }.not_to change(User,:count)
					end
					describe 'сообщение об ошибке,' do
						before { click_button(create_element) }
						it_should_behave_like 'появление flash-сообщения', 'error'
					end
					it_should_behave_like 'исчезновение flash-сообщения', 'error'
				end

				describe 'с частично верными данными,' do
					describe 'имя,' do
						before {
							fill_in 'Имя', with: 'Человече'
							click_button(create_element)
						}
						it_should_behave_like 'появление flash-сообщения', 'error'
					end
					describe 'электронная почта,' do
						before {
							fill_in 'Электронная почта', with: 'user@example.we'
							click_button(create_element)
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
				it_should_behave_like 'страница пользователя', 'своя', false
			end
			
			describe 'чужой страницы,' do
				before { visit user_path(other_user) }
				it_should_behave_like 'страница пользователя', 'чужая', false
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

		describe 'администратором,' do
			let(:admin) { FactoryGirl.create(:admin) }
			before { sign_in admin }

			describe 'своей,' do
				before { visit user_path(admin) }
				it_should_behave_like 'страница пользователя', 'своя', true
			end
			
			describe 'чужой,' do
				before { visit user_path(user) }
				it_should_behave_like 'страница пользователя', 'чужая', true
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
		let(:wrong_id) { User.maximum(:id)+1000 }

		describe 'НЕзарегистрированным,' do
			describe 'посещение,' do
				before { visit edit_user_path(user) }
				it_should_behave_like 'требование входа'
			end

			describe 'правка,' do
				before { patch user_path(user), user_params }
				specify { expect(response).to redirect_to login_path }
			end
		end
		
		describe 'зарегистрированным,' do

			describe 'посещение,' do
				before { sign_in user }
				
				describe 'своей,' do
					before { visit edit_user_path(user) }
					it_should_behave_like 'форма редактирования'
					describe 'форма редактирования -> страница редактирования'
				end

				describe 'чужой,' do
					before { visit edit_user_path(other_user) }
					it_should_behave_like 'появление flash-сообщения', 'error', 'Нельзя редактировать другого пользователя'
					it_should_behave_like 'страница пользователя', 'чужая', false
				end

				describe 'несуществующей,' do
					before { visit user_path(wrong_id) }
					it_should_behave_like 'появление flash-сообщения', 'error', 'Такой страницы не существует'
					it_should_behave_like 'страница с названием', title:'Пользователи'
				end
			end

			describe 'правка своей,' do
				before { 
					sign_in(user)
					visit edit_user_path(user)
				}

				describe '(4) с верными данными,' do
					let(:new_name) { Faker::Name.first_name }
					let(:new_email) { Faker::Internet.email }
					before {
						fill_in name_label, with: new_name
						fill_in email_label, with: new_email
						fill_in password_label, with: user.password
						fill_in password2_label, with: user.password
						click_button edit_element
					}
					it_should_behave_like 'появление flash-сообщения', 'success', 'Изменения приняты'
					it_should_behave_like 'страница пользователя', 'своя', false
					specify { expect(user.reload.name).to eq new_name }
					specify { expect(user.reload.email).to eq new_email }
				end

				describe '(5) c неверными данными,' do
					before { click_button edit_element }
					it_should_behave_like 'появление flash-сообщения', 'error'
					it_should_behave_like 'исчезновение flash-сообщения'
					specify { expect(user.reload.name).to eq user.name }
					specify { expect(user.reload.email).to eq user.email }
				end
			end

			describe 'правка не своей,' do
				before { sign_in(user, no_capybara:true) }

				describe 'чужой,' do
					before { patch user_path(other_user), user_params }
					
					specify{ expect(other_user.reload.name).not_to eq user_params[:user][:name] }
					specify{ expect(other_user.reload.email).not_to eq user_params[:user][:email] }

					specify{ expect(response).to redirect_to user_path(other_user) }
				end

				describe 'несуществующей,' do
					before { patch user_path(wrong_id), user_params }
					specify{ expect(response).to redirect_to users_path }
				end
			end
		end
	end

	describe 'удаление,' do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		let(:admin) { FactoryGirl.create(:admin) }
		let(:wrong_id) { User.maximum(:id)+1000 }

		describe 'НЕзарегистрированным пользователем,' do
			describe 'http-перенаправление,' do
				before { delete user_path(user) }
				specify { expect(response).to redirect_to(root_path) }
			end
			describe 'интактность БД,' do
				specify{ expect{delete user_path(user)}.not_to change(User,:count) }
			end
		end

		describe 'зарегистрированным пользователем,' do

			describe 'через web-интерфейс, своей' do
				before { 
					sign_in user 
					visit user_path(user)
					click_link delete_element
				}
				it_should_behave_like 'появление flash-сообщения', 'success', "Пользователь удалён"
				it_should_behave_like 'главная страница'
				it_should_behave_like 'НЕзарегистрированный пользователь'
			end

			describe 'http-запросом,' do
				before { sign_in user, no_capybara:true }
				
				describe 'своей,' do
					describe '1,' do
						specify{ expect{delete user_path(user) }.to change(User,:count).by(-1) }
					end
					
					describe '2,' do
						before { delete user_path(user) }
						specify{ expect(response).to redirect_to root_path }
					end
					
					describe '3,' do
						before { delete user_path(user) }
						specify{ expect(User.find_by(id:user.id)).to eq nil }
					end
				end

				describe 'чужой,' do
					describe '1,' do
						specify{ expect{ delete user_path(other_user) }.not_to change(User,:count) }
					end
					describe '2,' do
						before { delete user_path(other_user) }
						specify{ expect(response).to redirect_to root_path }
					end
				end

				describe 'несуществующей,' do
					specify{ expect{delete user_path(:wrong_id)}.not_to change(User,:count) }
					specify{ expect(response).to redirect_to root_path }
				end
			end
		end

		describe 'администратором,' do
			before { sign_in admin }

			describe 'своей,' do
				before {
					#sign_in admin
					visit user_path(admin)
				}
				specify{ expect{ click_link delete_element }.not_to change(User,:count) }
				it_should_behave_like 'появление flash-сообщения', 'Администратор не может удалить сам себя'
				it_should_behave_like 'страница пользователя', 'своя', true
			end

			describe 'чужой,' do
				before { visit user_path(user) }
				specify{ expect{ click_link delete_element }.to change(User,:count).by(-1) }
				it_should_behave_like 'появление flash-сообщения', 'success', "Пользователь удалён"
				it_should_behave_like 'страница с названием', title:'Пользователи'
			end	

			describe 'несуществующей,' do
				specify { expect{ delete user_path(wrong_id)}.not_to change(User,:count) }
				it_should_behave_like 'появление flash-сообщения', 'error', 'Несуществующий пользователь'
				it_should_behave_like 'страница с названием', title:'Пользователи'
			end

			# describe 'не своей,' do
			# 	before { sign_in admin, no_capybara:true }

			# 	describe 'чужой,' do
			# 		specify { expect{ delete user_path(user)}.to change(User,:count).by(-1) }
			# 		specify { expect{ delete user_path(other_user)}.to change(User,:count).by(-1) }
			# 	end

			# 	describe 'несуществующей,' do
			# 		specify { expect{ delete user_path(wrong_id)}.not_to change(User,:count) }
			# 	end
			# end
		end
	end

	pending 'защищённые параметры,' do
	end
end
