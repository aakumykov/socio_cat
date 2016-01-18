require 'spec_helper'

describe 'Категория' do
	let(:cat) { 
		Category.new(
			name: 'Категория 1',
			description: 'Описание «Категории 1»',
		)
	}
	let(:user) { FactoryGirl.create(:user) }

	subject { cat }

	it { should respond_to(:name) }
	it { should respond_to(:description) }
	it { should be_valid }

	describe 'Должна быть некорректной,' do
		context 'с пустым именем,' do
			before { cat.name = ' ' }
			it { should_not be_valid }
		end
		context 'с коротким именем,' do
			before { cat.name = 'А' }
			it { should_not be_valid }
		end
		context 'с длинным именем,' do
			before { cat.name = 'A'*50 }
			it { should_not be_valid }
		end
		context 'с повторяющимся именем,' do
			before { 
				cat.save!
				@cat2 = cat.dup
			}
			specify{ expect(@cat2).not_to be_valid }
		end

		context 'с пустым описанием,' do
			before { cat.description = ' ' }
			it { should_not be_valid }
		end
		context 'с коротким описанием,' do
			before { cat.description = 'А' }
			it { should_not be_valid }
		end
		context 'с длинным описанием,' do
			before { cat.description = 'А'*1000 }
			it { should_not be_valid }
		end
	end

	describe 'удаление концевых пробелов,' do
		let(:cat_name) { cat.name }
		let(:cat_description) { cat.description }
		before {
			cat.name = " "*5 + cat_name + "\t"*6
			cat.description = " "*5 + cat_description + "\t"*6
			cat.save!
		}
		specify{
			expect(cat.reload.name).to eq cat_name
			expect(cat.reload.description).to eq cat_description
		}
	end

	describe 'связь с карточками,' do
		
		# отзывчивость
		# обладание и порядок
		# разрушение

		let(:card1) { FactoryGirl.build(:card, user: user) }
		let(:card2) { FactoryGirl.build(:card, user: user) }

		before {
			cat.cards = [card1]
			cat.cards << card2
		}

		# отзывчивость
		it { should respond_to(:cards) }

		# обладание и порядок
		specify{ expect(cat.cards).to eq [card1,card2] }

		# разрушение
		describe 'при удалении категории карточки сохраняются,' do
			before { 
				cat.save!
				cat.destroy!
			}
			specify{ expect(Card.find_by(id:card1.id)).to eq card1 }
			specify{ expect(Card.find_by(id:card2.id)).to eq card2 }
		end
	end
end
