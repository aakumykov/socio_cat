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

	# before(:each) do
	# 	@card = Card.new(
	# 		title: 'Проверочная карточка',
	# 		content: 'Какое-нибудь содержимое',
	# 	)
	# end
	# subject { @card }

	# тестовая модель
	let(:card) {
		Card.new(
			title: 'Проверочная карточка',
			content: 'Какое-нибудь содержимое',
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
end
