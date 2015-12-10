class UsersController < ApplicationController

	public

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "Добро пожаловать на сайт!"
			sign_in @user
			redirect_to user_path(@user)
		else
			flash.now[:error] = 'ОШИБКА: пользователь не создан'
			render 'new'
		end
	end

	def show
		@user = User.find_by(id: params[:id])
	end

	def index
		@all_users = User.all
	end

	def edit
		@user = User.find_by(id:params[:id])
	end

	def update
		@user = User.find_by(params[:id])
		if @user.update_attributes(user_params)
			flash[:success] = "Изменения приняты"
			redirect_to user_path(@user)
		else
			flash.now[:error] = "Изменения отклонены"
			render 'edit'
		end
	end
	

	private

		def user_params
			params.require(:user).permit(
				:name,
				:email,
				:password,
				:password_confirmation,
			)
		end

end
