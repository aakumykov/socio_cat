class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	include SessionsHelper

	# Реализация предфильтров
	private
		def reject_nil_target
			the_model = controller_name.classify.constantize
			if the_model.find_by(id: params[:id]).nil?
				flash[:error] = 'Запрошенный объект не существует'
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
				flash[:error] = 'Вы уже зарегистрированы'
				redirect_to url_for(
								controller: controller_name, 
								action: 'show',
								id: current_user.id,
							)
			end
		end

		def admin_users
			if not current_user.admin?
				flash[:error] = 'Доступно только администратору'
				redirect_to url_for(
								controller: controller_name, 
								action: 'index',
							)
			end
		end
end
