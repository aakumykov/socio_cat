require 'spec_helper'

# (создание тестового объекта)
# прямые и связанные свойства модели
# валидность и другие свойства (be_)
# проверка того, что валидации работают
# отдельный метод
# поведение свойства
# поведение свойства
# отдельный случай поведения
# работа связей с другими моделями

describe 'Карточка,' do

	# тестовая модель
	let(:user) { FactoryGirl.create(:user) }

	let(:card) {
		user.cards.build(
			title: Faker::Lorem.word.capitalize,
			content: Faker::Lorem.paragraph,
		)
	}
	
	subject { card }


	### свойства
	## наличие
	it { should respond_to(:title) }
	it { should respond_to(:content) }

	## правильность
	# общая
	it { should be_valid }
	its(:user) { should eq user }

	# частная
	describe 'когда отсутствует заголовок,' do
		before { card.title = ' ' }
		it { should_not be_valid }
	end

	describe 'когда отсутствует содержимое,' do
		before { card.content = ' ' }
		it { should_not be_valid }
	end

	describe 'когда заголовок слишком длинный' do
		before { card.title = 'a'*1000 }
		it { should_not be_valid }
	end

	describe 'когда длина содержимого с лишком' do
		before { card.content = 'a'*10000 }
		it { should_not be_valid }
	end

	describe 'когда нет user_id,' do
		before{ card.user_id = nil }
		it { should_not be_valid }
	end


	describe 'удаление концевых пробелов,' do
		let(:card_title) { card.title }
		let(:card_content) { card.content }
		before {
			card.title = " "*5 + card_title + "\t"*6
			card.content = " "*5 + card_content + "\t"*6
			card.save!
		}
		specify{
			expect(card.reload.title).to eq card_title
			expect(card.reload.content).to eq card_content
		}
	end


	describe 'связь с пользователем,' do

		it 'должен иметь метод #user' do
			should respond_to(:user)
			should respond_to(:user_id)
		end

		it 'пользователь карточки тождественен пользователю' do
			expect(card.user).to eq user
		end

		describe 'удаление карточки сохраняет пользователя,' do
			before { card.destroy! }
			specify{ expect(User.find(card.user_id)).to eq user }
			specify{ expect(user.reload.id).to eq user.id }
			specify{ expect(user.reload).to eq user }
		end
	end

	describe 'связь с категориями,' do
		let(:cat1) { FactoryGirl.create(:category) }
		let(:cat2) { FactoryGirl.create(:category) }

		before {
			card.categorize([cat1.id, cat2.id])
			card.save!
		}

		it 'есть метод #categories' do
			should respond_to(:categories)
		end

		it 'категории карточки тождественны тестовым категориям,' do
			expect(card.categories).to eq [cat1,cat2]
		end

		describe 'удаление карточки сохраняет категорию,' do
			before { card.destroy! }
			specify {
				expect(Category.find(cat1.id)).to eq cat1
				expect(Category.find(cat2.id)).to eq cat2
			}
		end
	end
end
