require 'spec_helper'

describe 'Стриницы карточек,' do

	let(:user) { FactoryGirl.create(:user) }
	let(:other_user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:user) }

	let!(:card) { FactoryGirl.create(:card, user:user) }
	let!(:other_card) { FactoryGirl.create(:card, user:user) }

	let(:wrong_id) { Card.maximum(:id)+1 }

	let(:create_button) { 'Создать' }
	let(:change_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
	let(:cancel_button) { 'Отмена' }

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

	shared_examples_for 'требование входа' do
		it_should_behave_like 'страница входа'
		it_should_behave_like 'flash-сообщение', 'notice', 'Сначала войдите на сайт'
	end

	shared_examples_for 'страница карточек' do
		it_should_behave_like 'страница с названием' do
			let(:title) {'Карточки'}
			let(:heading) { title }
		end

		it_should_behave_like 'карточка' do
			let(:the_card) { card }
		end

		it_should_behave_like 'карточка' do
			let(:the_card) { other_card }
		end
	end

	shared_examples_for 'карточка' do
		it { should have_css("#card#{the_card.id}") }		
		it { should have_css(".card_title", text: the_card.title) }
		it { should have_css(".card_content") }
		
		it { should have_content(the_card.title) }
		it { should have_content(the_card.content) }
	end

	shared_examples_for 'редактирование карточки' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Редактирование карточки' }
			let(:heading) { title }
		end

		it { should have_field('Название', with: the_card.title) }
		#it { should have_xpath("//textarea['Содержимое', with: the_card.content) }
		#it { should have_xpath("//textarea[@id='card_content' and @value='#{the_card.content}']") }
		#it { should have_xpath("//textarea") }
		#it { should have_xpath("//input[@type='submit' and @value='#{save_button}']") }
		#it { should have_link(cancel_button, href: card_path(the_card.id)) }
	end



	describe 'предфильтры' do
		
		describe 'reject_nil_target()' do
			describe 'http,' do
				before { get card_path(wrong_id) }
				specify{ expect(response).to redirect_to(cards_path) }
			end

			describe 'www,' do
				before { visit card_path(wrong_id) }
				it_should_behave_like 'flash-сообщение', 'error', 'Нет такой карточки'
				it_should_behave_like 'страница карточек'
			end
		end

		describe 'signed_in_users()' do
			context 'гость,' do
				before { visit edit_card_path(card) }
				it_should_behave_like 'требование входа'
			end

			context 'пользователь,' do
				before { 
					sign_in user 
					visit edit_card_path(card)
				}
				it_should_behave_like 'редактирование карточки' do
					let(:the_card) { card }
				end
			end
		end

		describe 'editor_users()' do
			context 'не автор,' do
				before { 
					sign_in other_user
					visit edit_card_path(card)
				}
				it_should_behave_like 'flash-сообщение', 'error', 'Редактирование запрещено'
				it_should_behave_like 'карточка' do
					let(:the_card) { card }
				end
			end

			context 'автор,' do
				before {
					sign_in user
					visit edit_card_path(card)
				}
				it_should_behave_like 'редактирование карточки' do
					let(:the_card) { card }
				end
			end

			context 'администратор,' do
				# before {
				# 	sign_in admin
				# 	visit edit_card_path(card)
				# }
				# it_should_behave_like 'редактирование карточки' do
				# 	let(:the_card) { card }
				# end
				before {
					sign_in admin, no_capybara: true
					get edit_card_path(card)
				}
				specify{ expect(response).to redirect_to(edit_card_path(card)) }
				#specify{ expect(response).to render_template(:edit) }
			end
		end

		pending 'admin_users()'
	end

	pending 'список,'
	pending 'просмотр,'
	pending 'создание,'
	pending 'изменение,'
	pending 'удаление,'
end