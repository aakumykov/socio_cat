class UserMailer < ApplicationMailer
	default from: 'my.sender.personal@yandex.ru'
	layout 'user_mail'

	def welcome_message(arg)
		@user = arg[:user]
		@activation_code = arg[:activation_code]
		@subject = 'Добро пожаловать в соционический каталог'
		
		mail(
			to: @user.email,
			subject: @subject
		)
	end

	def activation_message(arg)
		@user = arg[:user]
		@activation_code = arg[:activation_code]
		@subject = 'Активация учётной записи на сайте Соционического каталога'
		
		mail(
			to: @user.email,
			subject: @subject
		)
	end

	def reset_message(arg)
		@url = url_for_password_reset(reset_code:arg[:reset_code], mode:'url')
		@user = arg[:user]
		@date = arg[:reset_date]
		@subject = 'Восстановление доступа в Соционический каталог'
		
		mail(
			to: @user.email,
			subject: @subject
		)
	end
end
