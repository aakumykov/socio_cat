require 'spec_helper'

describe 'Категории,' do
	let(:title) { 'Категории' }

	subject { page }

	shared_examples_for 'список_категорий' do
		it { should have_title(full_title(title)) }
		it { should have_selector('h1',title) }
	end

	describe 'Список,' do
		before { visit categories_path }
		it_should_behave_like 'список_категорий'
	end
	
	describe 'Создание,' do
	end

	describe 'Просмотр,' do
	end

	describe 'Изменение,' do
	end

	describe 'Удаление,' do
	end
end