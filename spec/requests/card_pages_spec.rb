require 'spec_helper'

describe 'Стриницы карточек,' do

	let(:create_button) { 'Создать' }
	let(:change_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
	let(:cancel_button) { 'Отмена' }

	let(:user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:user) }

	let!(:card1) { FactoryGirl.create(:card, user:user) }
	let!(:card2) { FactoryGirl.create(:card, user:user) }

	let(:wrong_id) { Card.maximum(:id)+1 }

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

	# shared_examples_for 'страница входа' do
	# 	it_should_behave_like 'страница с названием' do
	# 		let(:title) {'Вход на сайт'}
	# 		let(:heading) {'Вход на сайт'}
	# 	end

	# 	it { should have_selector('label',text:'Электронная почта') }
	# 	it { should have_selector(:xpath,"//input[@id='session_email']") }

	# 	it { should have_selector('label',text:'Пароль') }
	# 	it { should have_selector(:xpath,"//input[@id='session_password']") }

	# 	it { should have_selector(:xpath,"//input[@type='submit' and @value='Войти']")}
	# end

	# shared_examples_for 'требование входа' do
	# 	it_should_behave_like 'страница входа'
	# 	it_should_behave_like 'появление flash-сообщения', 'notice', 'Сначала войдите на сайт'
	# end

	shared_examples_for 'страница карточек' do
		it_should_behave_like 'страница с названием' do
			let(:title) {'Карточки'}
			let(:heading) { title }
		end

		it_should_behave_like 'карточка' do
			let(:the_card) { card1 }
		end

		it_should_behave_like 'карточка' do
			let(:the_card) { card2 }
		end
	end

	shared_examples_for 'карточка' do
		it { should have_selector("#card#{the_card.id}") }
		it { should have_selector(".card_title") }
		it { should have_selector(".card_content") }
		it { should have_content(the_card.title) }
		it { should have_content(the_card.content) }
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

		pending 'signed_in_users()'
		pending 'editor_users()'
		pending 'admin_users()'
	end

	pending 'список,'
	pending 'просмотр,'
	pending 'создание,'
	pending 'изменение,'
	pending 'удаление,'
end