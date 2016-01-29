class UserMailer < ApplicationMailer
	#default from: 'my.sender.personal@yandex.ru'

	def welcome_email(user)
		@user = user
		@url = 'http://localhost:3000/login'
		#@url = login_url
		#@url = login_path
		mail(
			from: 'my.sender.personal@yandex.ru',
			to: @user.email,
			subject: 'Добро пожаловать в соционический каталог'
		)
	end

	def reset_email(arg)
		@url = password_reset_url({code:arg[:code], date:arg[:date]})
		@title = 'Восстановление доступа в Соционический каталог'
		@user = arg[:user]
		@date = arg[:date]
		mail(
			from: 'my.sender.personal@yandex.ru',
			to: @user.email,
			subject: @title
		)
	end
end
