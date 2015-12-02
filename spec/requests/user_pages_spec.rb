require 'spec_helper'

describe 'Страницы пользователя,' do
	before(:all) {
		@user = FactoryGirl.create(:user)
	}
	subject { page }

	describe 'создание пользователя,' do
		before { visit new_user_path }
		it { should have_title(full_title('Регистрация пользователя')) }
		it { should have_selector('h1',text:'Регистрация пользователя') }

		it { should have_selector('lebel',text:'Имя') }
		it { should have_selector(:xpath, "//input[@name='user[name]']") }

		it { should have_selector('label', text:'Электронная почта') }
		it { should have_selector(:xpath, "//input[@name='user[email]']") }

		it { should have_selector(:xpath, "//input[@value='Создать']") }
	end

end