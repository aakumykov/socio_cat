require 'spec_helper'

describe 'Категории,' do
	let(:cat) { 
		Category.new(
			name: Faker::Lorem.word.capitalize, 
			description: Faker::Lorem.paragraph,
		) 
	}
	let(:other_cat) { 
		Category.new(
			name: Faker::Lorem.word.capitalize, 
			description: Faker::Lorem.paragraph,
		) 
	}

	subject { page }

	shared_examples_for 'список_категорий' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Категории' }
			let(:heading) { title }
		end
		pending 'элементы списка'
	end

	shared_examples_for 'форма категории' do
		it { should have_selector('label',text:'Название') }
		it { should have_field('name') }

		it { should have_selector('label',text:'Описание') }
		it { should have_field('description') }
	end


	pending 'Список,' do
		before { visit categories_path }
		it_should_behave_like 'список_категорий'
	end
	
	pending 'Создание,' do
		before { visit new_category_path }
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Новая категория' }
			let(:heading) { title }
		end
		it_should_behave_like 'форма категории'
		it_should_behave_like 'кнопка', value:'Создать'
		before { visit category_path(cat) }
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Новая категория' }
			let(:heading) { title }
		end
	end

	pending 'Просмотр,' do
	end

	describe 'Изменение,' do
	end

	describe 'Удаление,' do
	end
end