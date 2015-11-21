require 'spec_helper'

describe 'Стриницы карточек' do
	subject { page }

	describe 'список карточек,' do
		before { visit cards_path }

		it { should have_title('Список карточек') }
		it { should have_selector('h1','Список карточек') }
		
		describe 'одна карточка,' do
			let(:card_title) { '1st card title' }
			let(:card_content) { 'This is content of 1st card.' }
			let(:card) { FactoryGirl.create(:card, title: card_title, content: card_content) }
			
			it { should have_selector('fieldset.card') }
			it { should have_selector('legend.card_title',text: card_title) }
			it { should have_selector('div.card_content', text: card_content) }
		end
	end

end
