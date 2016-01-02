require 'spec_helper'
require 'shared/pages_specs'

describe 'Категории,' do
	let(:user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:admin) }

	let(:cat) { FactoryGirl.create(:category) }
	let(:other_cat) { FactoryGirl.create(:category) }

	let(:create_button) { 'Создать' }
	let(:edit_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }

	subject { page }

	shared_examples_for 'список_категорий' do
		it_should_behave_like 'страница с названием' do
			let(:title) { 'Категории' }
			let(:heading) { title }
		end
		it { should_not have_link('Новая',href:new_category_path) }

		pending 'элементы списка'
		
		describe 'кнопка создания категории,' do
			before { 
				sign_in user
				visit categories_path
			}
			it { should have_link('Новая',href:new_category_path) }
		end
	end

	shared_examples_for 'форма категории' do
		#it { should have_selector('label',text:'Имя') }
		#it { should have_field('name') }

		#it { should have_selector('label',text:'Описание') }
		#it { should have_field('description') }
		
		it { should have_field('Имя') }
		it { should have_field('Описание') }
	end

	shared_examples_for 'просмотр категории' do
		it_should_behave_like 'страница с названием' do
			let(:title) { "Категория «#{the_cat.name}»" }
			let(:heading) { title }
		end
		it { should have_content(the_cat.description) }
		it { should_not have_link('Изменить',href:edit_category_path(the_cat.id)) }
		it { should_not have_link('Удалить',href:category_path(the_cat.id)) }

		describe 'кнопка изменения,' do
			before { 
				sign_in user 
				visit category_path(cat)
			}
			it { should have_link('Изменить', href:edit_category_path(the_cat.id)) }
			it { should_not have_link('Удалить') }
		end

		describe 'кнопка удаления,' do
			before { 
				sign_in admin 
				visit category_path(cat)
			}
			it { should have_link('Удалить', href:category_path(the_cat.id)) }
		end
	end



	describe 'Список,' do
		before { visit categories_path }
		it_should_behave_like 'список_категорий'
	end
	
	describe 'Созидание,' do
		before { 
			sign_in user 
			visit new_category_path
		}

		describe 'форма,' do
			it_should_behave_like 'страница с названием' do
				let(:title) { 'Новая категория' }
				let(:heading) { title }
			end
			it_should_behave_like 'форма категории'
			it { should have_selector(:xpath,"//input[@type='submit' and @value='#{create_button}']") }
			pending 'Ищейка "конпка"'
		end

		describe 'работа формы,' do
			describe 'www,' do
				before {
					fill_in 'Имя', with: Faker::Lorem.word.capitalize
					fill_in 'Описание', with: Faker::Lorem.paragraph
				}

				describe 'страница с новой категорией,' do
					before { click_button create_button }
					it_should_behave_like 'flash-сообщение', 'success', text:"Категория создана"
					# it_should_behave_like 'просмотр категории' do
					# 	let(:the_cat) { Category.all.last }
					# end
				end

				# describe 'наполнение БД,' do
				# 	specify{ expect(click_button create_button).to change(Category,:count).by(1) }
				# end

				# it 'наполнение БД,' do
				# 	expect(click_button create_button).to change(Category,:count).by(1)
				# end
			end
		end
	end

	describe 'Просмотр,' do
		before { visit category_path(cat) }
		it_should_behave_like 'просмотр категории' do
			let(:the_cat) { cat }
		end
	end

	# describe 'Изменение,' do
	# 	# before { sign_in user }

	# 	# describe 'форма,' do
	# 	# 	before { visit edit_category_path(cat) }
	# 	# 	it_should_behave_like 'форма категории'
	# 	# 	it_should_behave_like 'кнопка', value: save_button
	# 	# 	it { should have_link('Отмена',href:category_path(cat)) }
	# 	# end

	# 	# describe 'работа формы,' do
	# 	# 	before {
	# 	# 		let(:new_cat) = Category.new(
	# 	# 			name: Faker::Lorem.word.capitalize,
	# 	# 			description: Faker::Lorem.paragraph,
	# 	# 		)
	# 	# 		fill_in 'Имя', with: new_cat.name
	# 	# 		fill_in 'Описание', with: new_cat.description
	# 	# 	}
	# 	# end
	# end

	# describe 'Разрушение,' do
	# end
end