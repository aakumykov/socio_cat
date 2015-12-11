include ApplicationHelper

def sign_in(user, no_capybara=false)
	if true==no_capybara
		remember_token = User.new_remember_token
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		cookie.permanent[:remember_token] = remember_token
	else	
		visit login_path 
		fill_in 'Электронная почта', with: user.name
		fill_in 'Пароль', with: user.password
		click_button 'Войти'
	end
end
