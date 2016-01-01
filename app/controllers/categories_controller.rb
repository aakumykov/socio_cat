class CategoriesController < ApplicationController

	include ResourceFiltersModule

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	before_action :signed_in_users, only: [:new, :create, :edit, :update]
	before_action :editor_users, only: [:edit, :update]
	before_action :admin_users, only: [:destroy, :block]

	def index
		@all_categories = the_model.all.order('created_at DESC')
	end

	def show
		@ctg = the_model.find(id: params[:id])
	end

	def new
	end

	def create
	end

	def update
		@ctg = the_target
		if @ctg.update_attributes(user_params)
			flash[:success] = 'Изменения сохранены'
			redirect_to category_path(@ctg)
		else
			flash.now[:error] = 'Изменения отклонены'
			render :edit
		end
	end

	def destroy
		@ctg = the_target
		if @ctg.destroy
			flash[:notice] = "Категория «#{ctg.name}» удалена"
			redirect_to url_for(controller: controller_name, action: 'index')
		else
			flash[:error] = "Ошибка удаления категории «#{ctg.name}»"
			redirect_to url_for(controller: controller_name, action: 'show', id: @ctg.id)
		end
	end

	private

		def the_model
			controller_name.classify.constantize
		end

		def the_target
			the_model.find_by(id: params[:id])
		end

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
