class UserMailer < ApplicationMailer
	default from: 'my.sender.personal@yandex.ru'
	layout 'user_mail'

	def welcome_message(arg)
		@user = arg[:user]
		@activation_code = arg[:activation_code]
		
		mail(
			to: @user.email,
			subject: 'Добро пожаловать в соционический каталог'
		)
	end

	def activation_message(arg)
		@user = arg[:user]
		@activation_code = arg[:activation_code]
		
		mail(
			to: @user.email,
			subject: 'Активация учётной записи на сайте Соционического каталога'
		)
	end

	def reset_message(arg)
		@url = url_for_password_reset(reset_code:arg[:reset_code], mode:'url')
		@title = 'Восстановление доступа в Соционический каталог'
		@user = arg[:user]
		@date = arg[:reset_date]
		mail(
			to: @user.email,
			subject: @title
		)
	end
end
