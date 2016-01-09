class CardsController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy, :categorize]
	before_action :signed_in_users, only: [:new, :create, :edit, :update]
	before_action :editor_users, only: [:edit, :update, :categorize]
	before_action :admin_users, only: [:destroy, :block]
	
	def create
		@card = current_user.cards.new(user_params)
		
		@card.cat_ids = category_params

		if @card.save
			flash[:success] = "Карточка создана"
			redirect_to card_path(@card)
		else
			flash.now[:error] = 'ОШИБКА, карточка не создана'
			render 'new'
		end
	end

	# def categorize
	# 	# @card устанавливается в фильтре editor_users
	# 	old_cats = Category.where(id: @card.categories.pluck(:id))
	# 	new_cats = old_cats.concat(Category.where(id: category_params)).uniq

	# 	if new_cats.blank?
	# 		flash[:error] = 'Список категорий пуст'
	# 	else
	# 		@card.categories=new_cats
	# 		flash[:success] = "Категории для «#{@card.title}» установлены"
	# 	end
	# 	redirect_to card_path
	# end

	private	

		def user_params
			params.require(:card).permit(
				:title,
				:content,
			)
		end

		def category_params
			params[:categories] ||= [nil]
			list = params.require(:categories).reject { |item| item.to_s.empty? }
			list.empty? ? nil : list
		end

		def editor_users
			@card = Card.find_by(id: params[:id])

			if (current_user != @card.user) && (not current_user.admin?)
				flash[:error] = 'Редактирование запрещено'
				redirect_to card_path(@card)
			end
		end
end

