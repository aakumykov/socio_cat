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
		#@obj = Object.new
		#@obj.email = ''
	end

	def reset_request
		params[:email] ||= ''
		email = params[:email]

		if email.blank?
			flash.now[:error] = 'Укажите адрес элетронной почты'
			render :reset_password
		elsif !email.match(/\A([a-z0-9+_]+[.-]?)*[a-z0-9]+@([a-z0-9]+[.-]?)*[a-z0-9]+\.[a-z]+\z/i)
			flash.now[:error] = 'Ошибка в адресе электронной почты'
			#@obj = Object.new
			#@obj.email = email
			render :reset_password
		else
			user = User.find_by(email: email)
			
			if user.nil?
				flash.now[:error] = 'Такого пользователя не существует'
				render :reset_password
			else
				reset_params = user.reset_password

				date = reset_params[:date]
				code = reset_params[:code]

				UserMailer.reset_email({
					user: user,
					code: code,
					date: date,
				}).deliver_now

				flash[:success] = 'Запрос принят'
				
				redirect_to root_path
			end
		end
	end

	def reset_response
		@user = User.find_by(reset_code: User.encrypt(params[:code]))

		begin
			raise 'не найден пользователь с таким кодом' if @user.nil? 
			raise 'пользователь не запрашивал восстановление пароля' if not @user.in_reset? 
		# 	raise 'код сброса пароля просрочен' if (Time.now - @user.reset_date) <= 24.hours 
		rescue Exception => e
			flash[:error] = "Ошибка: #{e.message}"
			redirect_to root_path
		end

		render :new_password
	end

	def new_password
		@user = User.find_by(id: params[:id])

		if @user.update_attributes(user_params)
			flash[:success] = "Новый пароль установен"
			redirect_to login_path
		else
			#flash[:error] 
			render :new_password
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

		def editor_users
			@user = User.find_by(id: params[:id])

			if (current_user != @user) && (not current_user.admin?)
				flash[:error] = 'Редактирование запрещено'
				redirect_to user_path(@user)
			end
		end
end
