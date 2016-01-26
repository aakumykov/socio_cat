class UserMailer < ApplicationMailer
	default from: 'user@example.org'

	def welcome_email(user)
		@user = user
		@url = 'http://localhost:3000/login'
		#@url = login_url
		#@url = login_path
		mail(
			to: @user.email,
			subject: 'Добро пожаловать в соционический каталог'
		)
	end
end
