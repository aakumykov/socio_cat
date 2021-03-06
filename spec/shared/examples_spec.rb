shared_examples_for 'flash-сообщение' do |mode,text=''|
	case mode
	when 'success'
		suffix = 'success'
	when 'info'
		suffix = 'info'
	when 'notice'
		suffix = 'notice'
	when 'warning'
		suffix = 'warning'
	when 'error' || 'danger'
		suffix = 'danger'
	else
		suffix = 'notice'
	end


	if text.blank?
		it { should have_selector("div.alert.alert-#{suffix}") }
	else
		it { should have_selector("div.alert.alert-#{suffix}", text:text) }
	end

	describe 'исчезновение flash-сообщения' do
		before { visit root_path }
		it { should_not have_selector("div.alert") }
	end
end

shared_examples_for 'вид_пользователя' do
	it { should_not have_link('Вход', href: login_path) }
	it { should have_link('Выход', href: logout_path) }
	it { should have_link('Пользователи', href: users_path) }
end

shared_examples_for 'вид_гостя' do
	it { should have_link('Вход', href: login_path) }
	it { should_not have_link('Выход', href: logout_path) }
	it { should_not have_link('Пользователи', href: users_path) }
end

shared_examples_for 'страница_с_названием' do
	it { should have_title( full_title(title) ) }
	it { should have_selector('h1',text:heading) }
end

shared_examples_for 'все_статические_страницы' do |mode=nil|
	if (nil.eql? mode || 'гость'==mode)
		context 'гость,' do
			it { should have_link('Главная страница', href: home_path) }
			it { should have_link('Категории', href: categories_path) }
			it { should have_link('Карточки', href: cards_path) }
			it { should have_link('О проекте', href: about_path) }
			it { should have_link('Помощь', href: help_path) }
			it { should have_link('Вход', href: login_path) }
			it { should have_link('Регистрация', href: new_user_path) }

			it { should_not have_link('Пользователи', href: users_path) }
			it { should_not have_link('Выход', href: logout_path) }
		end
	end
	
	if (nil.eql? mode || 'пользователь'==mode)
		context 'пользователь,' do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }
		
			it { should have_link('Пользователи', href: users_path) }
			it { should have_link("Профиль [#{user.name}]", href: user_path(user)) }
			it { should have_link('Выход', href: logout_path) }

			it { should_not have_link('Вход', href: login_path) }
		end
	end
end


shared_examples_for 'требование_входа' do
	it_should_behave_like 'страница_входа'
	it_should_behave_like 'flash-сообщение', 'warning', 'Сначала войдите на сайт'
end


shared_examples_for 'главная_страница' do
	it_should_behave_like 'страница_с_названием' do
		let(:title) { 'начало' }
		let(:heading) { 'Добро пожаловать' }
	end
end

shared_examples_for 'страница_входа' do
	let(:title) { 'Вход на сайт' }
	
	it { should have_title(full_title(title)) }
	it { should have_selector('h1',text:title) }
	
	it { should have_selector('label',text:'Электронная почта') }
	it { should have_selector(:xpath,"//input[@id='session_email']") }

	it { should have_selector('label',text:'Пароль') }
	it { should have_selector(:xpath,"//input[@id='session_password']") }
	
	it { should have_selector(:xpath,"//input[@type='submit']") }
	it { should have_selector(:xpath,"//input[@value='Войти']") }

	it { should have_link('Забыли пароль?', reset_password_path) }
	it { should have_link('Выслать письмо активации', activation_path) }
end

shared_examples_for 'страница_восстановления_пароля' do
	it_should_behave_like 'страница_с_названием' do
		let(:title) { 'Восстановление пароля' }
		let(:heading) { title }
	end
	it { should have_field 'Электронная почта' }
	it { should have_xpath("//input[@type='submit' and @value='Отправить']") }
end

shared_examples_for 'страница_нового_пароля' do
	it_should_behave_like 'страница_с_названием' do
		let(:title) { 'Создание нового пароля' }
		let(:heading) { title }
	end
	it { should have_field 'Новый пароль' }
	it { should have_field 'Подтверждение нового пароля' }
	it { should have_xpath "//input[@type='submit' and @value='#{new_password_button}']" }
	it { should have_xpath "//input[@type='hidden' and @id='user_reset_code']" }
	it { should have_xpath "//input[@type='hidden' and @id='user_id']" }
end


