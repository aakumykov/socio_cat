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


	# свойства
	it { should respond_to(:title) }
	it { should respond_to(:content) }


	# валидации
	it { should be_valid }

	describe 'когда отсутствует заголовок,' do
		before { card.title = ' ' }
		it { should_not be_valid }
	end

	describe 'когда отсутствует содержимое,' do
		before { card.content = ' ' }
		it { should_not be_valid }
	end
end
