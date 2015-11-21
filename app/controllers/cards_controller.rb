class CardsController < ApplicationController
	
	def index
		@all_cards = Card.all
	end

	
end
