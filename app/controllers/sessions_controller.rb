class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			flash[:success] = 'Вы вошли на сайт'
			sign_in(user)
			redirect_to user
		else
			flash.now[:error] = 'Неверная электронная почта или пароль'
			render 'new'
		end
	end

	def destroy

	end
	
end
