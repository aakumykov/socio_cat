require 'spec_helper'

describe 'Категории,' do
	let(:user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:admin) }

	let(:cat) { FactoryGirl.create(:category) }
	let(:new_cat) { FactoryGirl.build(:category) }
	let(:new_cat_data) {{
		category: {
			name: new_cat.name,
			description: new_cat.description,
	}}}

	let(:create_button) { 'Создать' }
	let(:edit_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
	let(:delete_button) { 'Удалить' }
	let(:cancel_button) { 'Отмена' }

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
				www_user
				visit categories_path
			}
			it { should have_link('Новая',href:new_category_path) }
		end
	end

	shared_examples_for 'форма_категории' do	
		it { should have_field('Имя') }
		it { should have_field('Описание') }
	end

	shared_examples_for 'просмотр_категории' do
		it_should_behave_like 'страница с названием' do
			let(:title) { "Категория «#{the_cat.name}»" }
			let(:heading) { title }
		end
		it { should have_content(the_cat.description) }
		it { should_not have_link(edit_button,href:edit_category_path(the_cat.id)) }
		it { should_not have_link(delete_button,href:category_path(the_cat.id)) }

		describe 'кнопка изменения,' do
			before { 
				www_user 
				visit category_path(cat)
			}
			it { should have_link(edit_button, href:edit_category_path(the_cat.id)) }
			it { should_not have_link(delete_button) }
		end

		describe 'кнопка удаления,' do
			before { 
				www_admin 
				visit category_path(cat)
			}
			it { should have_link(delete_button, href:category_path(the_cat.id)) }
		end
	end


	describe 'Список,' do
		before { visit categories_path }
		it_should_behave_like 'список_категорий'
	end

	describe 'Просмотр,' do
		before { visit category_path(cat) }
		it_should_behave_like 'просмотр_категории' do
			let(:the_cat) { cat }
		end
	end
	
	describe 'Созидание,' do
		describe 'www,' do
			before {
				www_user
				visit new_category_path
			}
			describe 'отображение формы,' do
				it_should_behave_like 'страница с названием' do
					let(:title) { 'Новая категория' }
					let(:heading) { title }
				end
				it_should_behave_like 'форма_категории'
				it { should have_selector(:xpath,"//input[@type='submit' and @value='#{create_button}']") }
				
				pending 'Ищейка "конпка"'
			end

			describe 'работа формы,' do
				context 'с верными данными,' do
					before {
						fill_in 'Имя', with: new_cat.name
						fill_in 'Описание', with: new_cat.description
					}
					# наполнение БД
					specify{ expect{ click_button create_button }.to change(Category,:count).by(1) }
					
					describe 'появление новых сведений в БД,' do
						before { click_button create_button }
						specify{ expect(Category.last.name).to eq(new_cat.name) }
						specify{ expect(Category.last.description).to eq(new_cat.description) }
					end

					describe 'уведомление об успехе,' do
						before { click_button create_button }
						it_should_behave_like 'flash-сообщение', 'success', 'Категория создана'
					end
				end

				context 'с ошибочными данными,' do
					specify{ expect{ click_button create_button }.not_to change(Category,:count) }

					describe 'уведомление об ошибке,' do
						before { click_button create_button }
						it_should_behave_like 'flash-сообщение', 'error', "Ошибка создания категории"
					end
				end
			end
		end

		# describe 'через http-запрос,' do
		# 	before { 
		# 		console_user 
		# 		post categories_path, new_cat_data
		# 	}
		# 	specify{ expect(response).to redirect_to(category_path(Category.last.id)) }
		# 	specify{ expect(response).to change(Category,:count).by(1) }
		# 	specify{ expect(response).to render_template(:show) }
		# 	specify{ expect(Category.last.name).to eq new_cat.name }
		# 	specify{ expect(Category.last.description).to eq new_cat.description }
		# end
	end

	pending 'Изменение,' do
	 	before { www_user }

		describe 'форма,' do
		 	before { visit edit_category_path(cat) }
		 	it_should_behave_like 'форма_категории'
			it { should have_selector(:xpath,"//input[@type='submit' and @value='#{save_button}']") }
		 	it { should have_link(cancel_button,href:category_path(cat)) }
		end

		describe 'работа формы,' do
			context 'с верными данными,' do
				before {
					fill_in 'Имя', with: new_cat.name
					fill_in 'Описание', with: new_cat.description
					click_button save_button
				}
			end

		end
	end

	# describe 'Разрушение,' do
	# end
end
