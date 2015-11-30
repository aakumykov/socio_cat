class CardsController < ApplicationController

	public
	
	def index
		@all_cards = Card.all
	end

	def new
		@card = Card.new
	end

	def create
		@card = Card.new(user_params)
		if @card.save
			flash[:success] = "Карточка «#{@card.title}» создана"
			redirect_to card_path(@card)
			#redirect_to cards_path
		else
			flash.now[:error] = 'Карточка не создана'
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
end

