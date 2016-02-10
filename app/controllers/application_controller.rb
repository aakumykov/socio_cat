class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	include SessionsHelper

	def index
		@list = the_model.all.order('created_at DESC')
	end

	def new
		@obj = the_model.new
	end

	def show
		@obj = the_model.find_by(id: params[:id])
	end

	def edit
		@obj = the_model.find_by(id: params[:id])
	end

	def update(obj=nil)
		if obj.nil?
			@obj = the_model.find_by(id: params[:id])
		else
			@obj = obj
		end

		if @obj.update_attributes(user_params)
			flash[:success] = 'Изменения сохранены'
			redirect_to url_for(
				controller: controller_name,
				action: 'show',
				id: @obj.id,
			)
		else
			flash.now[:danger] = 'Изменения отклонены'
			render :edit
		end
	end

	def destroy
		@obj = the_model.find_by(id: params[:id])
		if @obj.destroy
			flash[:warning] = "Объект удалён"
			redirect_to url_for(
					controller: controller_name,
					action: 'index',
				)
		else
			flash[:danger] = "Ошибка удаления"
			redirect_to url_for(
					controller: controller_name,
					action: 'show',
					id: @obj.id,
				)
		end
	end

	# Реализация предфильтров
	private
		def the_model
			controller_name.classify.constantize
		end

		def reject_nil_target
			the_model = controller_name.classify.constantize
			if the_model.find_by(id: params[:id]).nil?
				flash[:danger] = 'Запрошенный объект не существует'
				redirect_to url_for(
								controller: controller_name, 
								action: 'index',
							)
			end
		end

		def signed_in_users
			if not signed_in?
				redirect_to login_path, notice: 'Сначала войдите на сайт'
			end
		end

		def not_signed_in_users
			if signed_in?
				#puts "===== not_signed_in_users() =====: ЗАРЕГИСТРИРОВАН"
				flash[:danger] = 'Вы авторизованы на сайте'
				redirect_to url_for(
								controller: controller_name, 
								action: 'show',
								id: current_user.id,
							)
			else
				#puts "===== not_signed_in_users() =====: НЕ ЗАРЕГИСТРИРОВАН"
			end
		end

		def admin_users
			if not current_user.admin?
				flash[:danger] = 'Доступно только администратору'
				redirect_to url_for(
								controller: controller_name, 
								action: 'index',
							)
			end
		end
end
