require 'spec_helper'

describe 'Стриницы карточек' do
	subject { page }

	describe 'список карточек,' do
		before { visit cards_path }

		it { should have_title('Список карточек') }
		it { should have_selector('h1','Список карточек') }
	end

end