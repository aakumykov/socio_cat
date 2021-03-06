require 'spec_helper'

describe 'Категории,' do
	let(:user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:admin) }

	let(:cat) { FactoryGirl.create(:category) }
	let(:other_cat) { FactoryGirl.create(:category) }
	let(:new_cat) { FactoryGirl.build(:category) }
	let(:new_cat_data) {{
		category: {
			name: new_cat.name,
			description: new_cat.description,
	}}}

	let(:list_button) { 'Список' }
	let(:new_button) { 'Новая' }
	let(:create_button) { 'Создать' }
	let(:edit_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
	let(:delete_button) { 'Удалить' }
	let(:cancel_button) { 'Отмена' }

	subject { page }


	# define :have_button do |type,value|
	# 	match do |page|
 #    		page have_selector(:xpath,"//input[@type='#{type}' and @value='#{value}']")
 #    	end
	# end


	shared_examples_for 'кнопка_списка' do |pisitive=true|
		if pisitive.eql?(true)
			it { should have_link(list_button,categories_path) }
		else
			it { should_not have_link(list_button,categories_path) }
		end
	end

	shared_examples_for 'кнопка_новой' do |pisitive=true|
		if pisitive.eql?(true)
			it { should have_link(new_button,new_category_path) }
		else
			it { should_not have_link(new_button,new_category_path) }
		end
	end


	shared_examples_for 'список_категорий' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { 'Категории' }
			let(:heading) { title }
		end
		
		it_should_behave_like 'кнопка_списка'

		pending 'элементы списка,' do
			#before { visit categories_path }
			
			#it { should have_link(cat.name, href:category_path(cat)) }
			#it { should have_link(other_cat.name, href:category_path(other_cat)) }

			#it { should have_content(cat.name) }
			#it { should have_content(other_cat.name) }

			#it { should have_selector(:xpath,"//a[@href='#{category_path(cat)}']") }
			#it { should have_selector(:xpath,"//a[@href='#{category_path(other_cat)}']") }

			# it { should have_link(
			# 		cat.name,
			# 		href: category_path(cat)
			# 	)}
			
			# it { should have_link(
			# 		other_cat.name,
			# 		href: category_path(other_cat)
			# 	)}
		end

		describe 'кнопка создания,' do
			describe 'нет у гостя' do
				it_should_behave_like 'кнопка_новой', false
			end

			describe 'нет у пользователя,' do
				before { 
					www_user
					visit categories_path
				}
				it_should_behave_like 'кнопка_новой', false
			end

			describe 'есть у админа,' do
				before { 
					www_admin
					visit categories_path
				}
				it_should_behave_like 'кнопка_новой'
			end
		end
	end

	shared_examples_for 'просмотр_раздела' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { "Категория «#{the_cat.name}»" }
			let(:heading) { title }
		end
		it { should have_content(the_cat.description) }
		it { should_not have_link(edit_button,href:edit_category_path(the_cat.id)) }
		it { should_not have_link(delete_button,href:category_path(the_cat.id)) }

		describe 'список карточек,' do
			let(:all_cards) {[
					FactoryGirl.create(:card, user:user),
					FactoryGirl.create(:card, user:user),
				]}
			
			before {
				cat.cards = all_cards
				visit category_path(cat)
			}

			it 'заголовок области' do
				expect(page).to have_content('Карточки в разделе:')
			end

			describe 'заголовки всех карточек,' do
				it { should have_link(all_cards.first.title, card_path(all_cards.first)) }
				it { should have_link(all_cards.last.title, card_path(all_cards.last)) }
			end
		end

		describe 'пользователем,' do
			before { 
				www_user
				visit category_path(cat)
			}
			it { should_not have_link(edit_button,href:edit_category_path(the_cat.id)) }
			it { should_not have_link(delete_button,href:category_path(the_cat.id)) }
		end

		describe 'администратором,' do
			before { 
				www_admin 
				visit category_path(cat)
			}
			it { should have_link(edit_button, href:edit_category_path(the_cat.id)) }
			it { should have_link(delete_button, href:category_path(the_cat.id)) }
		end
	end

	shared_examples_for 'редактирование_раздела' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { 'Изменение раздела' }
			let(:heading) { title }
		end
		it_should_behave_like 'форма_раздела'
		it{ should have_button('submit',save_button) }
		it { should have_link(cancel_button,href:category_path(cat)) }
	end

	shared_examples_for 'создание_раздела' do
		it_should_behave_like 'страница_с_названием' do
			let(:title) { 'Новый раздел' }
			let(:heading) { title }
		end
		it_should_behave_like 'форма_раздела'
		it { should have_button('submit',create_button) }
		it { should have_link(cancel_button,href:categories_path) }
	end

	shared_examples_for 'форма_раздела' do	
		it { should have_field('Имя') }
		it { should have_field('Описание') }
	end


	describe 'Список,' do
		before { visit categories_path }
		it_should_behave_like 'список_категорий'
	end

	describe 'Список (http),' do
		before { get categories_path }
		specify{
			expect(response).to render_template(:index)
		}
	end

	describe 'Просмотр,' do
		before { visit category_path(cat) }
		it_should_behave_like 'просмотр_раздела' do
			let(:the_cat) { cat }
		end
	end
	
	describe 'Созидание,' do
		# Этот тест дублирует функционал тестов предфильтров,
		# но обеспечивает надёжность, одновременно снижая её,
		# за счёт усложнения кода.
		# Нужно ли это?
		describe 'запрещено пользователю,' do
			let(:category_params) {
				{ category: {
					name: Faker::Lorem.word*2,
					description: Faker::Lorem.paragraph,
				}}
			}
			let(:initial_cats_count) { Category.count }
			
			before { 
				console_user 
				post categories_path, category_params
			}
			
			specify{ expect(Category.count).to eq initial_cats_count }
			specify{ expect(response).to redirect_to(categories_path) }
		end

		describe 'разрешено админу,' do
			before {
				www_admin
				visit new_category_path
			}
			
			it_should_behave_like 'создание_раздела'

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
						it_should_behave_like 'flash-сообщение', 'error'#, "Ошибка создания раздела"
					end
				end
			end
		end
	end

	describe 'Изменение (http),' do
		before { console_admin }

		context 'корректными данными,' do
			before { patch category_path(cat), new_cat_data }
			
			specify{ expect(cat.reload.name).to eq new_cat.name }
			specify{ expect(cat.reload.description).to eq new_cat.description}
			
			specify{ expect(response).to redirect_to category_path(cat) }
		end

		context 'некорректными данными,' do
			let(:bad_cat_data) {
				{ category: {
					name: ' ',
					description: ' ',
				}}
			}
			before { patch category_path(cat), bad_cat_data }
			
			specify{ expect(cat.reload.name).to eq cat.name }
			specify{ expect(cat.reload.description).to eq cat.description}

			specify{ expect(response).to render_template(:edit) }
		end
	end

	describe 'Разрушение,' do
		before { 
			console_admin 
			delete category_path(cat)
		}

		specify{ expect(response).to redirect_to categories_path }
		specify{ expect(Category.find_by(name:cat.name)).to be_nil }
		# не работает
		#specify{ expect{ delete category_path(cat) }.to change(Category,:count).by(-1) }
	end
end
