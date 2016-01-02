shared_examples_for 'flash-сообщение' do |mode,text=''|
	if text.blank?
		it { should have_selector("div.alert.alert-#{mode}") }
	else
		it { should have_selector("div.alert.alert-#{mode}", text:text) }
	end

	describe 'исчезновение flash-сообщения' do
		before { visit root_path }
		it { should_not have_selector("div.alert") }
	end
end


shared_examples_for 'страница с названием' do
	it { should have_title( full_title(title) ) }
	it { should have_selector('h1',text:heading) }
end


shared_examples_for 'главная_страница' do
	it_should_behave_like 'страница с названием' do
		let(:title) { 'Соционический каталог' }
		let(:heading) { 'Добро пожаловать' }
	end
end


shared_examples_for 'страница_входа' do
	it_should_behave_like 'страница с названием' do
		let(:title) {'Вход на сайт'}
		let(:heading) {'Вход на сайт'}
	end

	it { should have_selector('label',text:'Электронная почта') }
	it { should have_selector(:xpath,"//input[@id='session_email']") }

	it { should have_selector('label',text:'Пароль') }
	it { should have_selector(:xpath,"//input[@id='session_password']") }

	it { should have_selector(:xpath,"//input[@type='submit' and @value='Войти']")}
end


shared_examples_for 'требование_входа' do
	it_should_behave_like 'страница_входа'
	it_should_behave_like 'flash-сообщение', 'notice', 'Сначала войдите на сайт'
end


shared_examples_for 'все статические страницы' do
	context 'гость,' do
		it { should have_link('Главная страница', href: home_path) }
		it { should have_link('Карточки', href: cards_path) }
		it { should have_link('О проекте', href: about_path) }
		it { should have_link('Помощь', href: help_path) }
		it { should have_link('Вход', href: login_path) }
		it { should have_link('Регистрация', href: new_user_path) }
	end
	
	context 'пользователь,' do
		let(:user) { FactoryGirl.create(:user) }
		before { sign_in user }
	
		it { should have_link('Пользователи', href: users_path) }
	end
end


shared_examples_for 'кнопка' do |opt|
	opt[:type] ||= 'submit'
	it { should have_selector(:xpath,"//input[@type='#{opt[:type]}' and @value='opt[:value]'") }
end