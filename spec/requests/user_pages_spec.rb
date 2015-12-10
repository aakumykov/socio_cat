require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:submit_button_create) { 'Создать' }
	let(:submit_button_edit) { 'Изменить' }

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

	shared_examples_for 'появление flash-сообщения' do |mode|

		it { should have_selector("div.alert.alert-#{mode}") }
	end

	shared_examples_for 'исчезновение flash-сообщения' do |mode|
		before { visit root_path }
		it { should_not have_selector("div.alert.alert-#{mode}") }
	end


	describe 'создание,' do
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

	describe 'список,' do
		before {
			@user1 = FactoryGirl.create(:user)
			@user2 = FactoryGirl.create(:user)
			visit users_path
		}
		it { should have_title('Пользователи') }
		it { should have_selector('h1', text: 'Пользователи') }
		it { should have_link(@user1.name, href:user_path(@user1)) }
		it { should have_link(@user2.name, href:user_path(@user2)) }
	end

	describe 'просмотр,' do
		before {
			@user = FactoryGirl.create(:user)
			visit user_path(@user) 
		}
		it_should_behave_like 'страница пользователя'
	end

	describe 'редактирование,' do
		before {
			@user = FactoryGirl.create(:user)
			visit edit_user_path(@user)
		}
		
		describe 'отображение,' do
			let(:title) { 'Редактирование пользователя' }
			it { should have_title(full_title(title)) }
			it { should have_selector('h1',text:title) }
			it_should_behave_like 'форма редактирования'
		end

		describe 'работа,' do
			let(:title) { 'Редактирование пользователя' }

			describe 'с неверными данными,' do
				let(:title) { 'Редактирование пользователя' }
				before {
					fill_in 'Имя', with:' '
					fill_in 'Электронная почта', with:' '
					fill_in 'Пароль', with:' '
					fill_in 'Подтверждение пароля', with:' '
					click_button submit_button_edit
				}
				it { should have_selector('.alert.alert-error') }
				it { should have_title(title) }
				it { should have_selector('h1',text:title) }
				specify { expect(@user.reload.name).to eq @user.name }
				specify { expect(@user.reload.email).to eq @user.email }
				it_should_behave_like 'исчезновение flash-сообщения', 'error'
			end

			describe 'с верными данными,' do
				before {
					@user2 = User.new(
						name: 'Пользователь 2',
						email: 'user2@example.com',
						password: 'Qwerty123!@#',
						password_confirmation: 'Qwerty123!@#',
					)
					
					fill_in 'Имя', with:@user2.name
					fill_in 'Электронная почта', with:@user2.email
					fill_in 'Пароль', with:@user2.password
					fill_in 'Подтверждение пароля', with:@user2.password_confirmation
					
					click_button submit_button_edit
				}
				
				it_should_behave_like 'страница пользователя'
				
				specify { expect(@user.reload.name).to eq @user2.name }
				specify { expect(@user.reload.email).to eq @user2.email }

				it_should_behave_like 'исчезновение flash-сообщения', 'success'
			end

		end
	end
end