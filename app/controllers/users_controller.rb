class UsersController < ApplicationController

	public

	def new
		@user = User.new
	end

	def create
		@user = User.create(user_params)
		if nil==@user
			flash.now[:error] = 'ОШИБКА: пользователь не создан'
			render 'new'
		else
			flash[:success] = "Создан пользователь «#{@user.name}»"
			redirect_to user_path(@user)
		end
	end

	def show
		@user = User.find_by(id: params[:id])
	end


	private

	def user_params
		params.require(:user).permit(
			:name,
			:email,
		)
	end

end
