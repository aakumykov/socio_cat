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
			#redirect_to card_path(@card)
			redirect_to cards_path
		else
			redirect_to(edit_card_path(@card))
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

