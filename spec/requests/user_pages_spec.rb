require 'spec_helper'

describe 'Страницы пользователя,' do
	before(:all) {
		let(:user) { FactoryGirl.create(:user) }
	}
	subject { page }

	describe 'создание пользователя,' do
		before { visit new_user_path }
		#subject { page }
		it { should have_title(full_title('Регистрация пользователя')) }
		it { should have_selector('h1','Регистрация пользователя') }
	end

end