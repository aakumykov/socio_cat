require 'spec_helper'

describe 'Статические welcome-страницы,' do
	subject { page }
	
	shared_examples_for 'all_welcome_pages' do
		it 'Соответствующий сложный <title>'
		it { should have_link('Главная страница', href: home_path) }
		it { should have_link('О проекте', href: about_path) }
		it { should have_link('Помощь', href: help_path) }
		it { should have_link('Карточки', href: cards_path) }
	end

	describe 'Главная страница,' do
		before { visit root_path }
		it { should have_selector('h1', text:'Добро пожаловать') }
		it_should_behave_like 'all_welcome_pages'
	end

	describe 'О проекте,' do
		before { visit about_path }
		it { should have_selector('h1', text:'О проекте') }
		it_should_behave_like 'all_welcome_pages'
	end

	describe 'Помощь,' do
		before { visit help_path }
		it { should have_selector('h1', text:'Помощь') }
		it_should_behave_like 'all_welcome_pages'
	end
end
