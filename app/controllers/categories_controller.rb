class CategoriesController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	before_action :signed_in_users, only: [:new, :create, :edit, :update]
	before_action :editor_users, only: [:edit, :update]
	before_action :admin_users, only: [:destroy, :block]

	def create
		@ctg = Category.new(user_params)
		if @ctg.save
			#flash[:success] = "Категория «#{@ctg.name}» создана"
			flash[:success] = "Категория создана"
			redirect_to category_path(@ctg)
		else
			flash.now[:error] = "Ошибка создания категории"
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
			@ctg = Category.find_by(id: params[:id])

			if (current_user != @ctg.user) && (not current_user.admin?)
				flash[:error] = 'Редактирование запрещено'
				redirect_to card_path(@ctg)
			end
		end
end
