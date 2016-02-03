class UserMailer < ApplicationMailer
	#default from: 'my.sender.personal@yandex.ru'

	def welcome_message(user)
		@user = user
		@url = login_url
		mail(
			from: 'my.sender.personal@yandex.ru',
			to: @user.email,
			subject: 'Добро пожаловать в соционический каталог'
		)
	end

	def reset_message(arg)
		@url = url_for_password_reset(reset_code:arg[:reset_code], mode:'url')
		@title = 'Восстановление доступа в Соционический каталог'
		@user = arg[:user]
		@date = arg[:reset_date]
		mail(
			from: 'my.sender.personal@yandex.ru',
			to: @user.email,
			subject: @title
		)
	end
end
