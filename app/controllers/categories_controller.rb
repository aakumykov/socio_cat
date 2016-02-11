class CategoriesController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	#before_action :signed_in_users, only: []
	#before_action :editor_users, only: []
	before_action :admin_users, only: [:new, :create, :edit, :update, :destroy, :block]

	def create
		@obj = Category.new(user_params)
		if @obj.save
			flash[:success] = "Категория создана"
			redirect_to category_path(@obj)
		else
			render :new
		end
	end

	private

		def user_params
			params.require(:category).permit(
				:name,
				:description,
			)
		end

		def editor_users
			@obj = Category.find_by(id: params[:id])

			if (current_user != @obj.user) && (not current_user.admin?)
				flash[:danger] = 'Редактирование запрещено'
				redirect_to card_path(@obj)
			end
		end
end
