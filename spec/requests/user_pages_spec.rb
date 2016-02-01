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


	shared_examples_for 'страница_пользователя' do |mode|
		it_should_behave_like 'страница_с_названием' do
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

	shared_examples_for 'страница_редактирования' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { "Редактирование пользователя «#{the_user.name}»" }
			let(:heading) { "Редактирование пользователя «#{the_user.name}»" }
		end
		it_should_behave_like 'форма_редактирования'
		it { should have_selector(:xpath,"//input[@type='submit' and @value='#{save_button}']") }
	end

	shared_examples_for 'список_пользователей' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { 'Пользователи' }
			let(:heading) { 'Пользователи' }
		end

		it { should have_link(user1.name, href:user_path(user1.id)) }
		it { should have_link(user2.name, href:user_path(user2.id)) }
	end

	shared_examples_for 'страница_регистрации' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { 'Регистрация пользователя' }
			let(:heading) { 'Регистрация пользователя' }
		end
		it_should_behave_like 'форма_редактирования'
		it { should have_selector(:xpath,"//input[@type='submit' and @value='#{register_button}']") }
	end

	shared_examples_for 'форма_редактирования' do
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
					www_user
					visit register_path
				}
				it_should_behave_like 'flash-сообщение', 'error', 'Вы зарегистрированный пользователь'
				it_should_behave_like 'страница_пользователя', 'владелец' do
					let(:the_user) { user }
				end
			end

			context 'невошедший пользователь,' do
				before { visit register_path }
				it_should_behave_like 'страница_регистрации'
			end
		end

		describe 'signed_in_users(),' do
			# должен отказывать не вошедшим

			context 'невошедший пользователь,' do
				before { visit user_path(user) }
				it_should_behave_like 'требование_входа'
			end

			context 'вошедший пользователь,' do
				before { 
					www_user
					visit user_path(user) 
				}
				it_should_behave_like 'страница_пользователя', 'владелец' do
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
				it_should_behave_like 'flash-сообщение', 'error', 'Редактирование запрещено'
				it_should_behave_like 'страница_пользователя' do
					let(:the_user) { user }
				end
			end

			context 'владелец,' do
				before { 
					www_user
					visit edit_user_path(user)
				}
				it_should_behave_like 'страница_редактирования' do
					let(:the_user) { user }
				end
			end

			context 'администратор,' do
				before { 
					www_admin 
					visit edit_user_path(user)
				}
				it_should_behave_like 'страница_редактирования' do
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
				before { console_admin }
				specify{ expect{ delete user_path(user) }.to change(User,:count).by(-1) }
			end
		end

		describe 'reject_nil_target(),' do
			# отклоняет действия над несуществующим пользователем

			before { www_user  }

			context 'объекта не существует' do
				before { visit user_path(wrong_id) }
				it_should_behave_like 'flash-сообщение', 'error', 'Запрошенный объект не существует'
				it_should_behave_like 'список_пользователей'
			end

			context 'объект существует' do
				before { visit user_path(user) }
				it_should_behave_like 'страница_пользователя', 'владелец' do
					let(:the_user) { user }
				end
			end
		end
	end


	# #new, #create
	describe 'регистрация пользователя,' do
		before { visit register_path }
		it_should_behave_like 'страница_регистрации'

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
					it_should_behave_like 'flash-сообщение', 'success', 'Добро пожаловать'
				end
			end
			context 'неверных,' do
				specify{ expect{ click_button register_button}.not_to change(User,:count) }

				describe 'уведомление об ошибке,' do
					before { click_button register_button }
					it_should_behave_like 'flash-сообщение', 'error', 'ОШИБКА. Пользователь не создан'
				end
			end
		end
	end

	# #index
	describe 'список пользователей,' do
		before { 
			www_user
			visit users_path
		}
		it_should_behave_like 'список_пользователей'
	end

	# #show, #edit. #update
	describe 'просмотр и редактирование пользователя,' do
		describe 'просмотр,' do
			before { 
				www_user
				visit user_path(user) 
			}
			it_should_behave_like 'страница_пользователя', 'владелец' do
				let(:the_user) { user }
			end
			
			describe 'редактирование,' do
				before { click_link edit_button }
				
				it_should_behave_like 'страница_редактирования' do
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
					 	
					 	it_should_behave_like 'страница_пользователя', 'владелец' do
					 		let(:the_user) { User.find_by(id: user.id) }
					 	end
					 end

					 describe 'неверное,' do
					 	before { click_button save_button }
					 	it_should_behave_like 'flash-сообщение', 'error', 'Изменения отклонены'
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
			www_admin
			visit user_path(user)
		}

		describe 'вид страницы,' do
			it_should_behave_like 'страница_пользователя', 'админ' do
				let(:the_user) { user }
			end
		end

		describe 'удаление кнопкой,' do
			describe 'уменьшение количества пользователей,' do
				specify{ expect{ click_link delete_button }.to change(User,:count).by(-1) }
			end
			
			describe 'сообщение об успехе,' do
				before { click_link delete_button }
				it_should_behave_like 'flash-сообщение', 'success', 'Пользователь'
				it_should_behave_like 'flash-сообщение', 'success', 'удалён'
				it_should_behave_like 'список_пользователей'
			end
		end
	end

	describe 'удаление админом самого себя,' do
		before { console_admin }
		
		specify{ expect{ delete user_path(admin) }.not_to change(User,:count) }

		describe 'перенаправление на страницу пользователя (админа),' do
			before { delete user_path(admin) }
			specify{ expect(response).to redirect_to user_path(admin) }
		end
	end

	# итого тест 7 действий

	describe 'запрещённые атрибуты,' do
		let(:params) {
			{ user: {
				name: Faker::Name.first_name,
				email: Faker::Internet.email,
				password: test_password,
				password_confirmation: test_password,
				admin: true,
				in_reset: true,
				in_pass_reset: true,
				reset_code: 'йцукен',
				reset_date: Time.at(0000000000),
			}}
		}
		before { 
			www_user 
			patch user_path(user), params
		}
		specify{ 
			expect(user.reload).not_to be_admin 
			expect(user.reload.in_reset).to be_false
			expect(user.reload.in_pass_reset).to be_false
			expect(user.reload.reset_date).not_to eq Time.at(0000000000)
			expect(user.reload.reset_code).not_to eq 'йцукен'
		}
	end

	describe 'восстановление пароля,' do
		let(:new_password_button) {'Установить'}
		let(:new_password) {'Abcdef123!@#'}
		let!(:reset_params) { user.reset_password }
		let(:reset_url) { url_for_password_reset(reset_code: reset_params[:reset_code]) }

		describe 'посещение страницы,' do
			describe 'пользователем,' do
				before {
					www_user
					visit reset_password_path
				}
				it_should_behave_like 'flash-сообщение', 'error', 'Вы зарегистрированный пользователь'
				it_should_behave_like 'страница_пользователя', 'владелец' do
					let(:the_user) { user }
				end
			end

			describe 'гостем,' do
				before { visit reset_password_path }
				it_should_behave_like 'страница_восстановления_пароля'
			end
		end

		describe 'отправка формы запроса на восстановление,' do
			before { visit reset_password_path }

			describe 'неверное заполненной,' do
				describe 'поле не заполнено,' do
					before { click_submit }
					it_should_behave_like 'flash-сообщение', 'error', 'Укажите адрес элетронной почты'
				end

				describe 'некорректный формат,' do
					before {
						fill_in 'Электронная почта', with: 'йцукен'
						click_submit
					}
					it_should_behave_like 'flash-сообщение', 'error', 'Ошибка в адресе электронной почты'
				end

				describe 'несуществующий пользователь,' do
					before { 
						fill_in 'Электронная почта', with: "#{SecureRandom.uuid}@example.com"
						click_submit
					}
					it_should_behave_like 'flash-сообщение', 'error', 'Такого пользователя не существует'
				end

				it_should_behave_like 'страница_восстановления_пароля'
			end
			
			describe 'верно заполненной,' do
				before {
					fill_in 'Электронная почта', with: user.email
					click_submit
				}
				it_should_behave_like 'flash-сообщение', 'success', 'На почтовый адрес отправлено сообщение с инструкциями'
				it_should_behave_like 'главная_страница'

				describe 'форма изменяет атрибуты и флаги,' do
					let!(:old_reset_code) { user.reset_code }
					let!(:old_reset_date) { user.reset_date }
					specify{
						expect(user.reload.in_reset).to be_true
						expect(user.reload.in_pass_reset).to be_true
						expect(user.reload.reset_date).not_to eq old_reset_code
						expect(user.reload.reset_code).not_to eq old_reset_date
					}
				end
			end
		end

		pending 'отправка почты со ссылкой сброса,'

		describe 'переход по ссылке сброса пароля,' do			
			describe 'пользователем,' do
				before {
					www_user
					visit reset_url
				}
				it_should_behave_like 'flash-сообщение', 'error', 'Вы зарегистрированный пользователь'
				it_should_behave_like 'страница_пользователя', 'владелец' do
					let(:the_user) { user }
				end
				specify{
					expect(user.reload.in_reset).to eq true
					expect(user.reload.in_pass_reset).to eq true
				}
			end
			
			describe 'гостем,' do
				describe 'с неверными параметрами,' do
					describe 'неверный код' do
						before {
							visit url_for_password_reset(reset_code: SecureRandom::uuid)
						}
						it_should_behave_like 'flash-сообщение', 'error', 'Ссылка недействительна'
						it_should_behave_like 'главная_страница'
					end
			 		
			 		describe 'сброшен флаг запроса на восстановление,' do
			 			before {
			 				user.toggle!(:in_reset)
			 				visit reset_url
			 			}
			 			it_should_behave_like 'flash-сообщение', 'error', 'Ссылка недействительна'
						it_should_behave_like 'главная_страница'
			 		end

					describe 'сброшен флаг смены пароля,' do
						before {
			 				user.toggle!(:in_pass_reset)
			 				visit reset_url
			 			}
			 			it_should_behave_like 'flash-сообщение', 'error', 'Ссылка недействительна'
						it_should_behave_like 'главная_страница'
					end

					pending 'неверное время'

					# pending 'post to new_password' должно работать только с флагом.
					# подумал: сейчас users#new_pasword "защищён" только html-страницей,
					# а нужно сделать флаго0зависимое поведение
				end

				pending 'с верными параметрами,' do
					
				end
			end
		end

		describe 'повторный переход по ссылке сброса пароля,' do
 			before {
 				visit reset_url
 				visit reset_url
 			}
 			
 			it_should_behave_like 'flash-сообщение', 'error', 'Ссылка недействительна'
			it_should_behave_like 'главная_страница'
			
			specify{
				expect(user.reload.in_reset).to be_false
				expect(user.reload.in_pass_reset).to be_false
			}
 		end

		describe 'отправка формы с новым паролем,' do

			let(:old_password_digest) { user.password_digest }
			
			let(:params) {
				{ user: {
					id: user.id,
					reset_code: reset_params[:reset_code],
					password: new_password,
					password_confirmation: new_password,
				} }
			}

			# это защита от "прямого доступа"
			describe 'сброшен флаг смены пароля,' do
				before {
					user.toggle!(:in_pass_reset)
					post new_password_path, params
				}
				specify{
					expect(user.reload.password_digest).to eq old_password_digest
					expect(user.authenticate(new_password)).to be_false
				}
			end

			describe 'флаг смены пароля стоит,' do
				describe 'id подменён,' do
					let(:bad_params) {
						params[:user].merge!({id: other_user.id})
						params
					}
					before {
						post new_password_path, bad_params
					}
					specify {
						expect(user.reload.password_digest).to eq old_password_digest
						# пароль у другого пользователя не должен меняться
						expect(other_user.reload.authenticate(new_password)).to be_false
					}
				end

				describe 'код сброса подменён,' do
					let(:bad_params) {
						params[:user].merge!({reset_code: SecureRandom.uuid})
						params
					}
					before {
						post new_password_path, bad_params
					}
					specify {
						expect(user.reload.password_digest).to eq old_password_digest
						expect(user.reload.authenticate(new_password)).to be_false
					}
				end

			# 	pending 'верная комбинация код-id,' do
			# 		before {
			# 			reset_params = user.reset_password
			# 			visit url_for_password_reset(reset_code:reset_params[:reset_code])
			# 		}
			# 		it_should_behave_like 'страница_нового_пароля'

			# 		describe 'установка нового пароля,' do
			# 			describe 'корректного,' do
			# 				before {
			# 					fill_in 'Новый пароль', with: new_password
			# 					fill_in 'Подтверждение нового пароля', with: new_password
			# 					click_button "#{new_password_button}"
			# 				}
			# 				specify{
			# 					expect(user.reload.authenticate(new_password)).not_to be_false
			# 				}
			# 				it_should_behave_like 'flash-сообщение', 'success', 'Новый пароль установлен'
			# 				it_should_behave_like 'страница_входа'
			# 			end

			# 			pending 'некорректного'
			# 			# pending 'валидация длины пароля' # работают, но проверять!
			# 		end
			# 	end
			end
		end

		pending 'сброс флага сброса пароля по успешному входу'
	end
end