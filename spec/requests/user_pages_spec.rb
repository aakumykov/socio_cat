require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:create_button) { 'Создать' }

	subject { page }


	shared_examples_for 'страница регистрации' do
		it { should have_title(full_title('Регистрация пользователя')) }
		it { should have_selector('h1',text:'Регистрация пользователя') }

		it { should have_selector('label',text:'Имя') }
		it { should have_selector(:xpath, "//input[@name='user[name]']") }

		it { should have_selector('label', text:'Электронная почта') }
		it { should have_selector(:xpath, "//input[@name='user[email]']") }

		it { should have_selector('label', text:'Пароль') }
		it { should have_selector(:xpath, "//input[@name='user[password]']") }

		it { should have_selector('label', text:'Подтверждение пароля') }
		it { should have_selector(:xpath, "//input[@name='user[password_confirmation]']") }

		it { should have_selector(:xpath, "//input[@value='Создать']") }
	end

	shared_examples_for 'страница пользователя' do
		it { should have_title(full_title('Страница пользователя')) }
		it { should have_selector('h1',text:'Страница пользователя') }
	end

	shared_examples_for 'ошибка регистрации' do
		it { should have_selector('.alert.alert-error', text:'ОШИБКА: пользователь не создан') }
		it { should have_selector('div.field_with_errors') }
	end


	describe 'создание,' do
		before { visit new_user_path }

		describe 'отображение формы,' do
			it_should_behave_like 'страница регистрации'
		end

		describe 'работа формы,' do
			
			describe 'с верными данными,' do
				#let(:test_password) { 'ОченьСложныйПароль123$%^' }
				let(:test_password) { 'Qwerty123!@#' }
				
				before {
					fill_in 'Имя', with: 'Человек'
					fill_in 'Электронная почта', with: 'homo@sapiens.me'
					fill_in 'Пароль', with: test_password
					fill_in 'Подтверждение пароля', with: test_password
				}
				
				it 'появление пользователя,' do
					expect{ click_button(create_button) }.to change(User, :count).by(1)
				end
				
				describe 'сообщение об успехе,' do
					before { 
						click_button(create_button) 
						@user = User.last
					}
					it { should have_selector('.alert.alert-success', text:"Создан пользователь «#{@user.name}»") }
				end
				
				describe 'перенаправление на страницу пользователя,' do
					before { click_button(create_button) }
					it_should_behave_like 'страница пользователя'
				end
			end
			
			describe 'с неверными данными,' do
				it 'отклонение нового пользователя,' do
					expect{ click_button(create_button) }.not_to change(User,:count)
				end
				describe 'сообщение об ошибке,' do
					before { click_button(create_button) }
					it_should_behave_like 'ошибка регистрации'
				end
			end

			describe 'с частично верными данными,' do
				describe 'имя,' do
					before {
						fill_in 'Имя', with: 'Человече'
						click_button(create_button)
					}
					it_should_behave_like 'ошибка регистрации'
				end
				describe 'электронная почта,' do
					before {
						fill_in 'Электронная почта', with: 'user@example.we'
						click_button(create_button)
					}
					it_should_behave_like 'ошибка регистрации'
				end
			end
		end
	end

end