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


	describe 'связь с пользователем,' do

		it 'должен иметь метод #user' do
			should respond_to(:user)
			should respond_to(:user_id)
		end

		it 'пользователь карточки тождественен пользователю' do
			expect(card.user).to eq user
		end

		describe 'удаление карточки не ведёт к удалению пользователя,' do
			before { card.destroy }
			specify{ expect(User.find(card.user_id)).to eq user }
			specify{ expect(user.reload.id).to eq user.id }
			specify{ expect(user.reload).to eq user }
		end
	end
end
