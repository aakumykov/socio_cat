class UsersController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	before_action :not_signed_in_users, only: [
		:new, 
		:create, 
		:reset_password, 
		:reset_response, 
		:activation, 
		:activation_response,
	]
	before_action :signed_in_users, only: [
		:index,
		:show, 
		:edit, 
		:update,
	]
	before_action :editor_users, only: [:edit, :update]
	before_action :admin_users, only: [:destroy]

	before_action :disable_page_caching, only: [:new_password]


	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			init_activation(@user)
			redirect_to root_path
		else
			#flash.now[:danger] = 'ОШИБКА. Пользователь не создан'
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
				flash.now[:danger] = 'Пользователь не найден'
				render :reset_password
			else
				reset_params = user.reset_password

				date = reset_params[:date]
				reset_code = reset_params[:reset_code]

				UserMailer.reset_message({
					user: user,
					reset_code: reset_code,
					reset_date: date,
				}).deliver_now

				flash[:success] = 'На почтовый адрес отправлено сообщение с инструкциями'
				
				redirect_to root_path
			end
		end
	end

	def reset_response
		#puts "===== users#reset_response ===== params: #{params}"

		@user = User.find_by(reset_code: User.encrypt(params[:reset_code]))

		begin
			if @user.nil? 
				raise 'не найден пользователь с таким кодом'
			end
			
			if not @user.in_reset?
				@user.drop_reset_flags
				raise 'пользователь не запрашивал восстановление пароля'
			end

			if not @user.in_pass_reset?
				@user.drop_reset_flags
				raise 'форма восстановления пароля неактивна'
			end

			if (Time.now - @user.reset_date).to_i > Rails.configuration.x.reset_password_link.lifetime
				# @user.drop_reset_flags (ЗАДЕЙСТВОВАТЬ?)
				raise "код сброса пароля просрочен"
			end
		rescue Exception => e
			#flash[:danger] = "Ссылка недействительна: #{e.message}"
			flash[:danger] = "Ссылка недействительна"
			redirect_to root_path
			return false
		end

		# ссылка работает только 1 раз
		@user.drop_reset_flags(:link)

		# форма нового пароля начинает жить
		@user.update_attribute(
			:new_pass_expire_time,
			Time.current + Rails.configuration.x.reset_password_form.lifetime
		)

		render :new_password, locals: {reset_code: params[:reset_code]}
	end

	def new_password
		#puts "=== users#new_password ===> params: #{params}"

		@user = User.find_by(
			id: params[:user][:id], 
			reset_code: User.encrypt(params[:user][:reset_code]),
		)

		begin
			if @user.nil?
				#puts "===== users#new_password ===> @user is nil"
				raise 'пользователь не найден'
			elsif !@user.in_pass_reset?
				#puts "===== users#new_password ===> форма неактивна"
				raise 'форма неактивна'
			elsif Time.current > @user.new_pass_expire_time
				#puts "===== users#new_password ===> форма просрочена"
				raise 'форма просрочена'
			else
				#puts "===== users#new_password ===> ПРОПУСКАЮ"
				if @user.update_attributes(user_params)
					@user.drop_reset_flags

					#puts "===== @user.new_pass_expire_time =====> #{@user.new_pass_expire_time}"
					@user.update_attribute(:new_pass_expire_time,Time.parse('1917/10/25'))
					#puts "===== @user.new_pass_expire_time =====> #{@user.new_pass_expire_time}"
					
					flash[:success] = "Теперь вы можете войти на сайт с новым паролем"
					
					redirect_to login_path
				else
					# уведомление об ошибке кажет форма
					render :new_password, locals: { reset_code: params[:user][:reset_code] }
				end
			end
		rescue Exception => e
			#puts "===== users#new_password ===> ПОЙМАЛ ИСКЛЮЧЕНИЕ"
			flash[:danger] = e.message
			redirect_to root_path
			return false
		end
	end

	def activation
		@user = User.new
	end

	def activation_request
		@user = User.find_by(email: params[:email])

		if @user
			init_activation(@user)
			redirect_to root_path
		else
			flash.now[:danger] = 'Не найден пользователь с такой электронной почтой'
			render :activation
		end
	end

	def activation_response
		@user = User.find_by(activation_code: User.encrypt(params[:code]))

		if @user
			#puts "===== контроллер: activation_response =====> пользователь найден (#{@user.name})"
			if !@user.activated?
				#puts "===== контроллер: activation_response =====> пользователь ещё не активирован"
				@user.activate
				
				sign_in @user
				flash[:success] = 'Добро пожаловать на сайт'
				redirect_to root_path
			else
				#puts "===== контроллер: activation_response =====> пользователь уже активирован"
				flash[:warning] = 'Пользователь уже активирован'
				redirect_to login_path
			end
		else
			#puts "===== контроллер: activation_response =====> пользователь не найден по коду #{User.encrypt(params[:code])}"
			flash[:danger] = 'Неверный код активации'
			redirect_to login_path
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

		def disable_page_caching
			#puts "===== disable_page_caching ====="
			response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
			response.headers['Pragma'] = 'no-cache'
			response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
		end

		def init_activation(user)
			data = user.new_activation

			UserMailer.delay(run_at: 5.seconds.from_now).welcome_message(
				user: user, 
				activation_code: data[:activation_code],
			)

			flash[:success] = 'Вам отправлено сообщение с кодом активации'
		end
end
