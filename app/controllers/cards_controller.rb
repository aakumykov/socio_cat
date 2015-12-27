class CardsController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]

	before_action :signed_in_users, only: [:new, :create, :edit, :update]
	before_action :editor_users, only: [:edit, :update]
	before_action :admin_users, only: [:destroy, :block]
	
	def index
		@all_cards = Card.all
	end

	def new
		@card = Card.new
	end

	def create
		@card = current_user.cards.new(user_params)
		if @card.save
			flash[:success] = "Карточка создана"
			redirect_to card_path(@card)
			#redirect_to cards_path
		else
			flash.now[:error] = 'ОШИБКА, карточка не создана'
			render 'new'
		end
	end

	def show
		@card = Card.find_by(id: params[:id])
		if nil==@card
			flash[:error] = 'Нет такой карточки'
			redirect_to cards_path
		end
	end

	def edit
		@card = Card.find_by(id: params[:id])
		if nil==@card
			flash[:error] = 'Нет такой карточки'
			redirect_to cards_path
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
		if nil==@card
			flash[:error] = "Ошибка удаления карточки"
			redirect_to cards_path
		elsif @card.destroy
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

		def reject_nil_target
			# if Card.find_by(id: params[:id]).nil?
			# 	flash[:error] = 'Нет такой карточки'
			# 	redirect_to cards_path
			# end
		end

		def signed_in_users
			if not signed_in?
				redirect_to login_path, notice: 'Сначала войдите на сайт'
			end
		end

		def editor_users
			@card = Card.find_by(id: params[:id])

			if (current_user != @card.user) && (not current_user.admin?)
				flash[:error] = 'Редактирование запрещено'
				redirect_to card_path(@card)
			end
		end

		def admin_users
			redirect_to cards_path if not current_user.admin?
		end

end

