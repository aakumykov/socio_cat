class UsersController < ApplicationController

	before_action :signed_in_users, only: [:index, :show, :edit, :update, :destroy] #да
	before_action :not_signed_in_users, only: [:new, :create] #да
	before_action :editor_users, only: [:edit, :update] #да
	before_action :destroy_users, only: [:destroy] # ещё нет

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
		if @user.nil?
			flash[:error] = 'Такой страницы не существует'
			redirect_to users_path
		end
	end

	def index
		@all_users = User.all
	end

	def edit
		# @user устанавливается в editor_users()
	end

	def update
		# @user устанавливается в editor_users()
		if @user.update_attributes(user_params)
			flash[:success] = "Изменения приняты"
			redirect_to user_path(@user)
		else
			flash.now[:error] = "Изменения отклонены"
			render 'edit'
		end
	end

	def destroy

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

		def signed_in_users
			if not signed_in?
				redirect_to login_path, notice: 'Сначала войдите на сайт'
			end
		end

		def not_signed_in_users
			if signed_in?
				flash[:notice] = 'Вы уже зарегистрированы'
				redirect_to user_path(current_user)
			end
		end

		def editor_users
			@user = User.find_by(id: params[:id])
			
			if @user.nil?
				redirect_to users_path
			elsif @user != current_user
				flash[:error] = 'Нельзя редактировать другого пользователя'
				redirect_to user_path(@user)
			end
		end

		def admin_users
			true
		end
end
