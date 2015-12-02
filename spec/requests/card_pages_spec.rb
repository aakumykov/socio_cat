require 'spec_helper'

describe 'Стриницы карточек,' do
	subject { page }

	let(:card_title) { 'Проверочный заголовок' }
	let(:card_content) { 'Проверочное наполнение (соционической функции).' }

	before(:each) {
		@card = FactoryGirl.create(:card, title: card_title, content: card_content)
		visit cards_path
	}

	shared_examples_for 'карточка' do
		it { should have_selector('fieldset.card') }
		it { should have_selector('legend.card_title',text: card_title) }
		it { should have_selector('div.card_content', text: card_content) }
	end

	shared_examples_for 'форма редактирования карточки' do
		#it { should have_title(full_title('Новая карточка')) }
		#it { should have_selector('h1', text:'Новая карточка') }

		it { should have_selector('label', text:'Название') }
		it { should have_selector(:xpath,'//input[@name="card[title]"]') }

		it { should have_selector('label', text:'Содержимое') }
		it { should have_selector(:xpath,'//textarea[@name="card[content]"]') }
	end

	shared_examples_for 'кнопка добавления карточки' do
		it { should have_link('Новая', href: new_card_path) }
	end

	# index
	# СДЕЛАТЬ: проверку того, что это именно список
	describe 'список,' do
		before(:each) { visit cards_path }

		it { should have_title('Список карточек') }
		it { should have_selector('h1','Список карточек') }
		it { should have_link('Новая', href: new_card_path) }
		
		describe 'одна карточка,' do
			it_should_behave_like 'карточка'

			#should have_selector(:xpath, "//fieldset[@id='card#{@card.id}']/legend//a[@href='#{card_path(@card.id)}']")}
			it_should_behave_like 'карточка'
			it_should_behave_like 'кнопка добавления карточки'
		end
	end

	# new
	describe 'создание,' do

		before(:each) { visit new_card_path }

		describe 'статика,' do
			it_should_behave_like 'форма редактирования карточки'
			it { should have_selector(:xpath,"//input[@value='Создать' and @name='commit']") }
		end

		describe 'динамика,' do
			
			describe 'с неверными данными,' do
				it 'карточка не должна создаваться' do
					expect { click_button 'Создать' }.not_to change(Card,:count)
				end
				
				describe 'сообщение об ошибке' do
					before { click_button 'Создать' }
					it { should have_selector('div.alert.alert-error', text:'ОШИБКА, карточка не создана') }
				end
				
				describe 'отображение формы редактирования карточки,' do
					it_should_behave_like 'форма редактирования карточки'
				end
			end

			describe 'с верными данными,' do
				before(:each) do
					fill_in 'Название', with: card_title
					fill_in 'Содержимое', with: card_content
				end

				it 'должна создаваться карточка,' do
					expect { click_button 'Создать'}.to change(Card, :count).by(1)
				end

				describe 'сообщение об успехе,' do
					before { click_button 'Создать' }
					it { should have_selector('div.alert.alert-success', text:"Карточка «#{@card.title}» создана") }
				end

				describe 'должна отображаться вновь созданная карточка,' do
					let(:title) { 'O_o' }
					before { click_button 'Создать' }
					
					it { should have_title(title) }
					it { should have_selector('h1',text:title) }

					it_should_behave_like 'карточка'
				end
			end

		end
	end

	# show
	describe 'просмотр одной,' do
		before {
			@card = Card.all.first
			visit card_path(@card.id)
		}

		it_should_behave_like 'карточка'
		it { should have_link('Изменить', edit_card_path(@card)) }
		it_should_behave_like 'кнопка добавления карточки'
	end

	# edit
	describe 'редактирование,' do
		let(:new_title) {@card.title + ' ИЗМЕНЕНО'}
		let(:new_content) {@card.content + ' ИЗМЕНЕНО'}

		before(:each) { 
			visit edit_card_path(@card)
		}
		
		describe 'форма,' do
			it_should_behave_like 'форма редактирования карточки'
			it { should have_selector(:xpath,"//input[@value='Сохранить' and @name='commit']") }
			it { should have_link('Отмена', href:card_path(@card)) }
		end

		describe 'сохранение изменений,' do
			before { 
				fill_in 'Название', with: new_title
				fill_in 'Содержимое', with: new_content
				click_button 'Сохранить'
			}
			
			it_should_behave_like 'карточка'
			it { should have_content(new_title) }
			it { should have_content(new_content) }
		end

		describe 'отказ от изменений,' do
			before {
		 		click_link 'Отмена'
		 	}
			
			it_should_behave_like 'карточка'

			it 'сохранение прежнего заголовка,' do
				should have_content(@card.title)
			end
			
			it 'сохранение прежнего содержимого,' do
				should have_content(@card.content)
			end
		 end
	end

	#destroy
	describe 'удаление,' do
		before { visit card_path(@card) }

		# штатная ситуаиця
		it 'кнопка удалить существует,' do
			page.should have_link('Удалить', href: card_path(@card))
		end

		it 'кнопка удалить работает,' do
			expect{ click_link 'Удалить'}.to change(Card,:count).by(-1)
		end

		describe 'перенаправление после удаления,' do
			before { click_link 'Удалить' }
			it { should have_selector('h1',text: 'Список карточек') }
		end

		# нештатная ситуаиця
		describe 'удаление несуществующей карточки' do
			specify { 
				expect { delete card_path(Card.last.id+1) }.not_to change(Card,:count) 
			}
			before {
				delete card_path(Card.last.id+1)
			}
			specify {
				expect(response).to redirect_to(cards_path)
			}
			#subject { page }
			#it { should have_selector('div.alert.alert-error', text:'Ошибка удаления карточки') }
			#it { should have_content('Список') }
			#it { should have_selector('div') } # работает только это
		end
	end

end
