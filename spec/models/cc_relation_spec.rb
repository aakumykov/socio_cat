require 'spec_helper'

describe 'Связь карточек с категорями' do
	# План:
	# отзывчивость
	# тождественность
	# удаление

	let(:category) { FactoryGirl.create(:category) }
	let(:card) { FactoryGirl.create(:card) }

	let(:rel) { 
		CcRelation.create!(
			category_id: category.id,
			card_id: card.id,
		)
	}

	subject{ rel }

	it { should be_valid }

	# отзывчивость
	it { should respond_to(:card) }
	it { should respond_to(:category) }
	
	# тождественность
	its(:card) { should eq card }
	its(:category) { should eq category }

	# удаление
	describe 'удаление связи сохраняет карточку и категорию,' do
		before { rel.destroy! }
		specify{ expect(Card.find_by(id:card.id)).to eq card }
		specify{ expect(Category.find_by(id:category.id)).to eq category }
	end
end