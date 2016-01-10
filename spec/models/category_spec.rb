require 'spec_helper'

describe 'Категория' do
	let(:cat) { 
		Category.new(
			name: 'Категория 1',
			description: 'Описание «Категории 1»',
		)
	}

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

	pending 'связь с карточками,' do
		# let(:card) { FactoryGirl.create(:card, category:) }
		# before {
		# 	cat.
		# }

		# it { should respond_to(:cards) }
	end
end
