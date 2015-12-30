require 'spec_helper'

describe 'Статические welcome-страницы,' do
	subject { page }
	
	shared_examples_for 'all_welcome_pages' do
		context 'гость,' do
			it { should have_link('Главная страница', href: home_path) }
			it { should have_link('Категории', href: categories_path) }
			it { should have_link('Карточки', href: cards_path) }
			it { should have_link('О проекте', href: about_path) }
			it { should have_link('Помощь', href: help_path) }
			it { should have_link('Вход', href: login_path) }
			it { should have_link('Регистрация', href: new_user_path) }
		end
		
		context 'пользователь,' do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }
		
			it { should have_link('Пользователи', href: users_path) }
		end
	end

	describe 'Главная страница,' do
		before { visit root_path }
		it { should have_title(full_title('Соционический каталог')) }
		it { should have_selector('h1', text:'Добро пожаловать') }
		it_should_behave_like 'all_welcome_pages'
	end

	describe 'О проекте,' do
		let(:title) { 'О проекте' }
		before { visit about_path }
		it { should have_title(full_title(title)) }
		it { should have_selector('h1', text:title) }
		it_should_behave_like 'all_welcome_pages'
	end

	describe 'Помощь,' do
		let(:title) { 'Помощь' }
		before { visit help_path }
		it { should have_title(full_title(title)) }
		it { should have_selector('h1', text:title) }
		it_should_behave_like 'all_welcome_pages'
	end
end
