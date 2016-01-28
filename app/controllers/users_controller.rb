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
			UserMailer.welcome_email(@user).deliver_now!
			sign_in @user
			flash[:success] = "Добро пожаловать, «#{@user.name}»!"
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
		#if @user.update_attributes!(params[:user])
		# if 
		# 	@user.update_attribute(:name,params[:user][:name]) && 
		# 	@user.update_attribute(:email,params[:user][:email]) && 
		# 	@user.update_attribute(:password,params[:user][:password]) && 
		# 	@user.update_attribute(:password_confirmation,params[:user][:password_confirmation]) &&
		# 	@user.update_attribute(:admin,params[:user][:admin]) 
			
			flash[:success] = "Изменения профиля приняты"
			redirect_to user_path(@user)
		else
			flash.now[:error] = "Изменения отклонены"
			render 'edit'
		end
	end

	def destroy
		@user = User.find_by(id: params[:id])

		if @user.admin? 
			flash[:error] = 'Админ не может удалить себя'
			redirect_to user_path(@user)
		else				
			if @user.destroy
				flash[:success] = "Пользователь «#{@user.name}» удалён"
				@user=nil
			else
				flash[:error] = "Ошибка удаления пользователя «#{@user.name}»"
			end

			redirect_to users_path
		end
	end
	
	def reset_password
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

		def editor_users
			@user = User.find_by(id: params[:id])

			if (current_user != @user) && (not current_user.admin?)
				flash[:error] = 'Редактирование запрещено'
				redirect_to user_path(@user)
			end
		end
end
