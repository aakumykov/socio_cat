class UsersController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]

	before_action :not_signed_in_users, only: [:new, :create]
	before_action :signed_in_users, only: [:show, :edit, :update]
	before_action :editor_users, only: [:edit, :update]
	before_action :admin_users, only: [:destroy]


	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "Добро пожаловать на сайт, «#{@user.name}»!"
			sign_in @user
			redirect_to user_path(@user)
		else
			flash.now[:error] = 'ОШИБКА. Пользователь не создан'
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
			flash[:success] = "Изменения профиля приняты"
			redirect_to user_path(@user)
		else
			flash.now[:error] = "Изменения отклонены"
			render 'edit'
		end
	end

	def destroy
		@user = User.find_by(id: params[:id])

		if @user.destroy
			flash[:success] = "Пользователь «#{@user.name}» удалён"
			@user=nil
		else
			flash[:error] = "Ошибка удаления пользователя «#{@user.name}»"
		end
		
		redirect_to users_path
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

		def reject_nil_target
			#if params[:id].nil? || User.find_by(id: params[:id]).nil?
			if User.find_by(id: params[:id]).nil?
				flash[:error] = 'Несуществующий объект'
				redirect_to root_path
			end
		end

		def signed_in_users
			if not signed_in?
				redirect_to login_path, notice: 'Сначала войдите на сайт'
			end
		end

		def not_signed_in_users
			if signed_in?
				flash[:error] = 'Вы уже зарегистрированы'
				redirect_to user_path(current_user)
			end
		end

		def editor_users
			@user = User.find_by(id: params[:id])

			if (current_user != @user) && (not current_user.admin?)
				flash[:error] = 'Нельзя редактировать другого пользователя'
				redirect_to user_path(@user)
			end
		end

		def admin_users
			if not current_user.admin?
				flash[:error] = 'Доступно только администратору'
				redirect_to root_path
			end
		end
end
