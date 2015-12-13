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

# def sign_in(user, options={})
#   if options[:no_capybara]
#     # Sign in when not using Capybara.
#     remember_token = User.new_remember_token
#     cookies[:remember_token] = remember_token
#     user.update_attribute(:remember_token, User.encrypt(remember_token))
#   else
#     visit signin_path
#     fill_in "Email",    with: user.email
#     fill_in "Password", with: user.password
#     click_button "Sign in"
#   end
# end