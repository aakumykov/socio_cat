class UsersController < ApplicationController

	before_action :signed_in_user, only: [:index, :show] #да
	before_action :not_signed_in_user, only: [:new, :create] #да
	before_action :correct_user, only: [:edit, :update] # ещё нет
	before_action :admin_user, only: [:destroy] # ещё нет

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
		redirect_to users_path if @user.nil?
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

		def signed_in_user
			if not signed_in?
				#save_referer
				redirect_to login_path, notice: 'Сначала войдите на сайт'
			end
		end

		def not_signed_in_user
			if signed_in?
				#save_referer
				redirect_to user_path(current_user), notice:'Вы уже зарегистрированы'
			end
		end

		def correct_user
			true
		end

		def admin_user
			true
		end
end
