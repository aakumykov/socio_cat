require 'spec_helper'

describe 'Стриницы карточек,' do

	let(:user) { FactoryGirl.create(:user) }
	let(:other_user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:admin) }

	let!(:card) { FactoryGirl.create(:card, user:user) }
	let!(:other_card) { FactoryGirl.create(:card, user:user) }

	let(:wrong_id) { Card.maximum(:id)+1 }

	let(:create_button) { 'Создать' }
	let(:change_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
	let(:cancel_button) { 'Отмена' }

	def console_user
		sign_in user, no_capybara: true
	end
	
	def console_admin
		sign_in admin, no_capybara: true
	end

	subject { page }


	shared_examples_for 'flash-сообщение' do |mode,text=''|
		if text.blank?
			it { should have_selector("div.alert.alert-#{mode}") }
		else
			it { should have_selector("div.alert.alert-#{mode}", text:text) }
		end
		
		describe 'исчезновение flash-сообщения' do
			before { visit root_path }
			it { should_not have_selector("div.alert") }
		end
	end

	shared_examples_for 'страница с названием' do
		it { should have_title( full_title(title) ) }
		it { should have_selector('h1',text:heading) }
	end

	shared_examples_for 'страница входа' do
		it_should_behave_like 'страница с названием' do
			let(:title) {'Вход на сайт'}
			let(:heading) {'Вход на сайт'}
		end

		it { should have_selector('label',text:'Электронная почта') }
		it { should have_selector(:xpath,"//input[@id='session_email']") }

		it { should have_selector('label',text:'Пароль') }
		it { should have_selector(:xpath,"//input[@id='session_password']") }

		it { should have_selector(:xpath,"//input[@type='submit' and @value='Войти']")}
	end

	shared_examples_for 'требование_входа' do
		it_should_behave_like 'страница входа'
		it_should_behave_like 'flash-сообщение', 'notice', 'Сначала войдите на сайт'
	end

	shared_examples_for 'список_карточек' do
		it_should_behave_like 'страница с названием' do
			let(:title) {'Карточки'}
			let(:heading) { title }
		end

		it_should_behave_like 'просмотр_карточки' do
			let(:the_card) { card }
		end

		it_should_behave_like 'просмотр_карточки' do
			let(:the_card) { other_card }
		end
	end

	shared_examples_for 'просмотр_карточки' do
		it { should have_css("#card#{the_card.id}") }		
		it { should have_css(".card_title", text: the_card.title) }
		it { should have_css(".card_content") }
		
		it { should have_content(the_card.title) }
		it { should have_content(the_card.content) }
		it { should have_content("от #{the_card.user.name}") }
	end

	shared_examples_for 'редактирование_карточки' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Редактирование карточки' }
			let(:heading) { title }
		end
		it { should have_field('Название', with: the_card.title) }
		it { should have_field('Содержимое', with: the_card.content) }
		it { should have_link(cancel_button, href: card_path(the_card.id)) }
		it { should have_xpath("//input[@type='submit' and @value='#{save_button}']") }
	end
	
	shared_examples_for 'создание_карточки' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Создание карточки' }
			let(:heading) { title }
		end
		it { should have_field('Название') }
		it { should have_field('Содержимое') }
		it { should have_link(cancel_button) }
		it { should have_xpath("//input[@type='submit' and @value='#{create_button}']") }
	end
	
	# shared_examples_for 'форма_карточки' do
	# 	it { should have_field('Название', with: the_card.title) }
	# 	it { should have_field('Содержимое', with: the_card.content) }
	# 	it { should have_link(cancel_button, href: card_path(the_card.id)) }
	# end



	describe 'предфильтры,' do
		
		describe 'reject_nil_target()' do
			describe 'http,' do
				before { get card_path(wrong_id) }
				specify{ expect(response).to redirect_to(cards_path) }
			end

			describe 'www,' do
				before { visit card_path(wrong_id) }
				it_should_behave_like 'flash-сообщение', 'error', 'Нет такой карточки'
				it_should_behave_like 'список_карточек'
			end
		end

		describe 'signed_in_users()' do
			context 'гость,' do
				before { visit new_card_path }
				it_should_behave_like 'требование_входа'
			end

			context 'пользователь,' do
				before { 
					sign_in user, no_capybara:true
					get new_card_path
				}
				specify{ expect(response).to render_template(:new) }
			end
		end

		describe 'editor_users()' do
			context 'не автор,' do
				before {
					sign_in other_user, no_capybara: true
					get edit_card_path(card)
				}
				specify{ expect(response).to redirect_to(card_path(card)) }
			end

			context 'не автор www,' do
				before {
					sign_in other_user
					visit edit_card_path(card.id)
				}
				it_should_behave_like 'flash-сообщение', 'error', 'Редактирование запрещено'
			end

			context 'автор,' do
				before {
					sign_in user, no_capybara: true
					get edit_card_path(card)
				}
				specify{ expect(response).to render_template(:edit) }
			end

			context 'администратор,' do
				before {
					sign_in admin, no_capybara: true
					get edit_card_path(card)
				}
				specify{ expect(response).to render_template(:edit) }
			end
		end

		describe 'admin_users()' do
			context 'не админ' do
				let!(:cards_count) { Card.all.count }
				before {
					console_user
					delete card_path(card)
				}
				specify{ expect(response).to redirect_to(cards_path) }
				specify{ expect(cards_count).to eq Card.all.count }
			end
			
			context 'админ' do
				before { console_admin }
				specify{ expect{ delete card_path(card) }.to change(Card,:count).by(-1) }
			end

			pending 'уведомления предфильтра admin_users пока не тестируются' do
			end
		end
	end

	describe 'список,' do
		before { visit cards_path }
		it_should_behave_like 'список_карточек'
	end

	describe 'просмотр,' do
		before { visit card_path(card) }
		it_should_behave_like 'просмотр_карточки' do
			let(:the_card) { card }
		end
	end

	describe 'создание,' do

		let(:card_params) {
			{ card: {
				title: Faker::Lorem.word.capitalize,
				content: Faker::Lorem.paragraph,
				user: user,
			}}
		}

		let(:new_card) { 
			Card.new(
				title: card_params[:card][:title],
				content: card_params[:card][:content],
				user: user,
			)
		}

		describe 'www,' do
			before { 
				sign_in user 
				visit new_card_path
			}

			describe 'вид,' do
				it_should_behave_like 'создание_карточки'
			end

			describe 'работа,' do
				before {
					fill_in 'Название', with: new_card.title
					fill_in 'Содержимое', with: new_card.content
					click_button create_button
				}
				it_should_behave_like 'просмотр_карточки' do
					let(:the_card) { Card.last }
				end
				it_should_behave_like 'flash-сообщение', 'success', 'Карточка создана'
			end
		end

		describe 'http,' do
			before {
				console_user
				post cards_path, card_params
			}
			specify{ expect(response).to redirect_to card_path(Card.last) }
		end
	end

	describe 'изменение,' do
		let(:new_title) {card.title + ' ' + Faker::Lorem.word}
		let(:new_content) {Faker::Lorem.paragraph}

		let(:new_card_params) {
			{ card: {
				title: new_title,
				content: new_content,
				user: user,
			}}
		}

		before {
			console_user
			patch card_path(card), new_card_params
		}
		specify{ expect(response).to redirect_to card_path(card) }
		
		specify{ expect(card.reload.title).to eq new_title}
		specify{ expect(card.reload.content).to eq new_content}
	end

	describe 'удаление,' do
		before { console_admin }
		
		describe 'изменение БД,' do
			specify{ expect{ delete card_path(card) }.to change(Card,:count).by(-1) }
		end

		describe 'перенаправление к списку,' do
			before { delete card_path(card) }
			specify{ expect(response).to redirect_to(cards_path) }
		end
	end
end
