class UsersController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	before_action :not_signed_in_users, only: [:new, :create, :reset_password, :reset_response]
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
			flash.now[:danger] = 'ОШИБКА. Пользователь не создан'
			render 'new'
		end
	end

	def show
		@user = User.find_by(id: params[:id])
		if @user.nil?
			flash[:danger] = 'Такой страницы не существует'
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
			flash[:success] = 'Изменения профиля сохранены'
			redirect_to user_path(@user)
		else
			flash.now[:danger] = 'Изменения отклонены'
			render 'edit'
		end
	end

	def destroy
		@user = User.find_by(id: params[:id])

		if @user.admin? 
			flash[:danger] = 'Админ не может удалить себя'
			redirect_to user_path(@user)
		else				
			if @user.destroy
				flash[:success] = "Пользователь «#{@user.name}» удалён"
				@user=nil
			else
				flash[:danger] = "Ошибка удаления пользователя «#{@user.name}»"
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
			flash.now[:danger] = 'Укажите адрес элетронной почты'
			render :reset_password
		elsif !email.match(/\A([a-z0-9+_]+[.-]?)*[a-z0-9]+@([a-z0-9]+[.-]?)*[a-z0-9]+\.[a-z]+\z/i)
			flash.now[:danger] = 'Ошибка в адресе электронной почты'
			#@obj = Object.new
			#@obj.email = email
			render :reset_password
		else
			user = User.find_by(email: email)
			
			if user.nil?
				flash.now[:danger] = 'Такого пользователя не существует'
				render :reset_password
			else
				reset_params = user.reset_password

				date = reset_params[:date]
				reset_code = reset_params[:reset_code]

				UserMailer.reset_email({
					user: user,
					reset_code: reset_code,
					date: date,
				}).deliver_now

				flash[:success] = 'На почтовый адрес отправлено сообщение с инструкциями'
				
				redirect_to root_path
			end
		end
	end

	def reset_response
		#puts "===== users#reset_response ===== params: #{params}"

		@user = User.find_by(reset_code: User.encrypt(params[:reset_code]))
		#@user and puts "===== @user.name,email,in_reset =====> #{@user.name},#{@user.email},#{@user.in_reset}"

		begin
			raise 'не найден пользователь с таким кодом' if @user.nil? 
			raise 'пользователь не запрашивал восстановление пароля' if not @user.in_reset?
			raise 'форма восстановления пароля неактивна' if not @user.in_pass_reset?
		# 	raise 'код сброса пароля просрочен' if (Time.now - @user.reset_date) <= 24.hours 
		rescue Exception => e
			# === кривовато, но работает и избавляет от повторений ===
			flash[:danger] = 'Ссылка недействительна'
			redirect_to root_path
			return false
			# === кривовато, но работает и избавляет от повторений ===
		end

		# ссылка работает только 1 раз
		@user.disable_pass_reset

		render :new_password, locals: {reset_code: params[:reset_code]}
	end

	def new_password
		#puts "=== users#new_password ===> params[:user][:id]: #{params[:user][:id]}"
		#puts "=== users#new_password ===> params[:user][:reset_code]: #{params[:user][:reset_code]}"
		puts "=== users#new_password ===> params: #{params}"

		@user = User.find_by(
			id: params[:user][:id], 
			reset_code: User.encrypt(params[:user][:reset_code]),
		)

		begin
			if @user.nil?
				puts "===== users#new_password ===> @user is nil"
				raise 'пользователь не найден'
			elsif !@user.in_pass_reset?
				puts "===== users#new_password ===> форма неактивна"
				raise 'форма неактивна'
			else
				puts "===== users#new_password ===> ПРОПУСКАЮ"
				if @user.update_attributes(user_params)
					@user.disable_pass_reset
					flash[:success] = "Новый пароль установлен"
					redirect_to login_path
				else
					# уведомление об ошибке кажет форма
					render :new_password, locals: { reset_code: params[:user][:reset_code] }
				end
			end
		rescue Exception => e
			puts "===== users#new_password ===> ПОЙМАЛ ИСКЛЮЧЕНИЕ"
			flash[:danger] = e.message
			redirect_to root_path
			return false
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
				flash[:danger] = 'Редактирование запрещено'
				redirect_to user_path(@user)
			end
		end
end
