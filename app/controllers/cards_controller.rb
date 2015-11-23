class CardsController < ApplicationController
	
	def index
		@all_cards = Card.all
	end

	def new
		@card = Card.new
	end

	
end
