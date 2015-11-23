require 'spec_helper'

describe 'Стриницы карточек' do
	subject { page }

	describe 'список карточек,' do
		before(:each) { visit cards_path }

		it { should have_title('Список карточек') }
		it { should have_selector('h1','Список карточек') }
		
		describe 'одна карточка,' do
			let(:card_title) { '1st card title' }
			let(:card_content) { 'This is content of 1st card.' }
			
			before(:each) {
				FactoryGirl.create(:card, title: card_title, content: card_content)
				visit cards_path
			}
			
			it { should have_selector('fieldset.card') }
			it { should have_selector('legend.card_title',text: card_title) }
			it { should have_selector('div.card_content', text: card_content) }
		end
	end

	describe 'создание карточки,' do

		before(:each) { visit new_card_path }

		
		describe 'статические элементы,' do
			it { should have_title(full_title('Новая карточка')) }
			it { should have_selector('h1', text:'Новая карточка') }

			it { should have_selector('label', text:'Название') }
			it { should have_selector(:xpath,'//input[@name="card[title]"]') }

			it { should have_selector('label', text:'Содержимое') }
			it { should have_selector(:xpath,'//textarea[@name="card[content]"]') }

			it { should have_selector(:xpath,'//input[@value="Создать" and @name="commit"]') }
		end


		describe 'действия,' do
			
			describe 'с неверными данными,' do
				it 'карточка не должна создаваться'
				it 'должно выводиться сообщение об ошибке'
				it 'должна появляться форма редактирования'
			end

			describe 'с верными данными,' do
				before(:each) do
					fill_in 'Название', with: 'Проверочный заголовок'
					fill_in 'Содержимое', with: 'Проверочное наполнение (соционической функции).'
				end

				it 'должна создаваться карточка,' do
					expect { click_button 'Создать'}.to change(Card, :count).by(1)
				end

				# expect 'должна создаваться карточка,' do
				# 	click_button 'Создать'
				# end.to change(Card, :count).by(1)

				it 'должно выводиться сообщение об успехе'
				it 'должна отображаться вновь созданная карточка'
			end

		end
	end

end
