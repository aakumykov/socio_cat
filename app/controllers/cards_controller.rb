class CardsController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	before_action :signed_in_users, only: [:new, :create, :edit, :update]
	before_action :editor_users, only: [:edit, :update]
	before_action :admin_users, only: [:destroy, :block]
	
	def create
		@card = current_user.cards.new(user_params)
		if @card.save
			flash[:success] = "Карточка создана"
			redirect_to card_path(@card)
		else
			flash.now[:error] = 'ОШИБКА, карточка не создана'
			render 'new'
		end
	end

	def update
		@card = Card.find_by(id: params[:id])
		if @card.update_attributes(user_params) then
			flash[:success] = 'Карточка изменена'
		else
			flash[:error] = 'Ошибка изменения карточки'
		end
		redirect_to card_path(@card)
	end

	def destroy
		@card = Card.find_by(id: params[:id])
		if @card.destroy
			flash[:warning] = "Карточка «#{@card.title}» удалена"
			redirect_to cards_path
		else
			flash[:error] = "Ошибка удаления карточки «#{@card.title}»"
			redirect_to card_path(@card)
		end
	end

	private	

		def user_params
			params.require(:card).permit(
				:title,
				:content,
			)
		end

		def editor_users
			@card = Card.find_by(id: params[:id])

			if (current_user != @card.user) && (not current_user.admin?)
				flash[:error] = 'Редактирование запрещено'
				redirect_to card_path(@card)
			end
		end
end

