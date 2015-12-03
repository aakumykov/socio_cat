class UsersController < ApplicationController

	public

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "Создан пользователь «#{@user.name}»"
			redirect_to user_path(@user)
		else
			flash.now[:error] = 'ОШИБКА: пользователь не создан'
			render 'new'
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
