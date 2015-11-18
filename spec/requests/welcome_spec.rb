require 'spec_helper'

describe 'Статические welcome-страницы,' do
	subject { page }
	
	describe 'Главная страница,' do
		before { visit root_path }
	
		it { should have_selector('h1', text:'Добро пожаловать') }

		describe 'Ссылки на разделы,' do
			it { should have_link('Главная страница', href: home_path) }
			it { should have_link('О проекте', href: about_path) }
			it { should have_link('Помощь', href: help_path) }
		end
	end
end
