class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	include SessionsHelper

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]

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


end
