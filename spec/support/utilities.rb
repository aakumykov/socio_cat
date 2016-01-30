include ApplicationHelper

def sign_in(user, opt={})
	if opt[:no_capybara]
		remember_token = User.new_remember_token
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		cookies[:remember_token] = remember_token
	else	
		visit login_path 
		fill_in 'Электронная почта', with: user.email
		fill_in 'Пароль', with: user.password
		click_button 'Войти'
	end
end

def click_submit
	find(:xpath,"//input[@type='submit']").click
end
