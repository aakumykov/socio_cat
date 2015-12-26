class SessionsController < ApplicationController

	def new
		save_referer
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		
		if user && user.authenticate(params[:session][:password])
			flash[:success] = "Добро пожаловать на сайт, «#{user.name}»!"
			sign_in(user)
			redirect_back
			#redirect_to user_path(user)
		else
			flash.now[:error] = 'Неверная электронная почта или пароль'
			render 'new'
		end
	end

	def destroy
		#save_referer

		sign_out
		flash[:success] = 'Вы вышли с сайта'
		
		redirect_to login_path
	end
	
end
