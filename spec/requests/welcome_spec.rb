require 'spec_helper'
require 'shared/pages_specs'

describe 'Статические welcome-страницы,' do
	subject { page }
	

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
