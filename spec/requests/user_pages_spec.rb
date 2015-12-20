require 'spec_helper'

describe 'Страницы пользователя,' do

	let(:create_button) { 'Создать' }
	let(:edit_button) { 'Изменить' }
	let(:delete_button) { 'Удалить' }

	let(:test_password) { 'Qwerty123!@#' }

	subject { page }


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

	shared_examples_for 'страница пользователя' do
		it { should have_title( full_title("Страница пользователя «#{page_user.name}»") ) }
		it_should_behave_like 'данные пользователя' do
			let(:data_user) { page_user }
		end
	end

	shared_examples_for 'данные пользователя' do
		it { should have_content('Имя:') }
		it { should have_content(data_user.name) }
		
		it { should have_content('Электронная почта:') }
		it { should have_content(data_user.email) }
	end

	shared_examples_for 'страница входа' do
		#it_should_behave_like 'страница с названием', title:'Вход на сайт'
		it { should have_selector(:xpath,"//input[@type='submit']")}
		it { should have_selector(:xpath,"//input[@value='Войти']")}
	end


	describe 'предфильтры,' do
		pending 'Один тест на группу! Следи за правильным включением предфильтров!'

		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		let(:admin) { FactoryGirl.create(:admin) }
		let(:wrong_id) { User.maximum(:id)+1 }

		describe 'not_signed_in_users(),' do
			context 'невошедший пользователь,' do
				before { visit user_path(user) }
				it_should_behave_like 'страница входа'
			end

			context 'вошедший пользователь,' do
				before {
					sign_in user
					visit user_path(user)
				}
				it_should_behave_like 'страница пользователя' do
					let(:page_user) { user }
				end
			end
		end
	end


end