require 'spec_helper'

describe 'Стриницы карточек,' do
	subject { page }

	let(:card_title) { '1st card title' }
	let(:card_content) { 'This is content of 1st card.' }

	shared_examples_for 'карточка' do
		it { should have_selector('fieldset.card') }
		it { should have_selector('legend.card_title',text: card_title) }
		it { should have_selector('div.card_content', text: card_content) }
	end

	shared_examples_for 'форма редактирования карточки' do
		it { should have_title(full_title('Новая карточка')) }
		it { should have_selector('h1', text:'Новая карточка') }

		it { should have_selector('form#new_card') }

		it { should have_selector('label', text:'Название') }
		it { should have_selector(:xpath,'//input[@name="card[title]"]') }

		it { should have_selector('label', text:'Содержимое') }
		it { should have_selector(:xpath,'//textarea[@name="card[content]"]') }

		it { should have_selector(:xpath,'//input[@value="Создать" and @name="commit"]') }
	end

	describe 'список,' do
		before(:each) { visit cards_path }

		it { should have_title('Список карточек') }
		it { should have_selector('h1','Список карточек') }
		it { should have_link('Новая', href: new_card_path) }
		
		describe 'одна карточка,' do
			before(:each) {
				FactoryGirl.create(:card, title: card_title, content: card_content)
				visit cards_path
			}
			
			it_should_behave_like 'карточка'
		end
	end

	describe 'создание,' do

		before(:each) { visit new_card_path }

		describe 'статика,' do
			it_should_behave_like 'форма редактирования карточки'
		end

		describe 'динамика,' do
			
			describe 'с неверными данными,' do
				it 'карточка не должна создаваться' do
					expect { click_button 'Создать' }.not_to change(Card,:count)
				end
				
				describe 'сообщение об ошибке' do
					before { click_button 'Создать' }
					it { should have_selector('div.alert.alert-error', text:'Ошибка') }
				end
				
				describe 'отображение формы редактирования карточки,' do
					it_should_behave_like 'форма редактирования карточки'
				end
			end

			describe 'с верными данными,' do
				before(:each) do
					fill_in 'Название', with: 'Проверочный заголовок'
					fill_in 'Содержимое', with: 'Проверочное наполнение (соционической функции).'
				end

				it 'должна создаваться карточка,' do
					expect { click_button 'Создать'}.to change(Card, :count).by(1)
				end

				describe 'сообщение об успехе,' do
					before { click_button 'Создать' }
					it { should have_selector('div.alert.alert-success', text:'Карточка создана') }
				end

				describe 'должна отображаться вновь созданная карточка,' do
					before { click_button 'Создать' }
					it { should have_selector('h1',text:'Просмотр карточки') }
					it_should_behave_like 'карточка'
				end
			end

		end
	end

end
