require 'spec_helper'

describe 'Статические welcome-страницы,' do
	subject { page }

	shared_examples_for 'все статические страницы' do
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
			#it { should have_link('Мой профиль') }
			it { should have_link("Профиль [#{user.name}]", href: user_path(user)) }
		end
	end	

	describe 'Главная страница,' do
		before { visit home_path }
		it_should_behave_like 'главная_страница'
		it_should_behave_like 'все статические страницы'
	end

	describe 'О проекте,' do
		before { visit about_path }
		it_should_behave_like 'страница с названием' do
			let(:title) { 'О проекте' }
			let(:heading) { title }
		end
		it_should_behave_like 'все статические страницы'
	end

	describe 'Помощь,' do
		before { visit help_path }
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Помощь' }
			let(:heading) { title }
		end
		it_should_behave_like 'все статические страницы'
	end
end
