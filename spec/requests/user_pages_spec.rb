require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:create_button) { 'Создать' }

	subject { page }

	describe 'создание,' do
		before { visit new_user_path }

		describe 'отображение формы,' do
			it { should have_title(full_title('Регистрация пользователя')) }
			it { should have_selector('h1',text:'Регистрация пользователя') }

			it { should have_selector('label',text:'Имя') }
			it { should have_selector(:xpath, "//input[@name='user[name]']") }

			it { should have_selector('label', text:'Электронная почта') }
			it { should have_selector(:xpath, "//input[@name='user[email]']") }

			it { should have_selector(:xpath, "//input[@value='Создать']") }
		end

		describe 'работа формы,' do
			
			describe 'с верными данными,' do
				before {
					fill_in 'Имя', with: 'Человек'
					fill_in 'Электронная почта', with: 'homo@sapiens.me'
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
					it { should have_title(full_title('Страница пользователя')) }
					it { should have_selector('h1',text:'Страница пользователя') }
				end
			end
			
			# describe 'с неверными данными,' do
			# 	it 'отклонение нового пользователя,' do
			# 		expect{ click_button('Создать') }.not_to change(User,:count)
			# 	end
			# 	it { should have_selector('.alert.alert-error', text:'ОШИБКА: пользователь не создан') }
			# end
		end
	end

end