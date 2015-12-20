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

	shared_examples_for 'страница c названием' do
		#it { should have_title( full_title(the_title) ) }
		it { should have_title( full_title("Страница пользователя «#{the_user.name}»") ) }
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
				it_should_behave_like 'страница c названием' do
					#let(:the_title) { "Страница пользователя «#{user.name}»"}
					let(:the_user) { user }
				end
			end
		end
	end


end