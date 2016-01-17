class CardsController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy, :categorize]
	before_action :signed_in_users, only: [:new, :create, :edit, :update]
	before_action :editor_users, only: [:edit, :update, :categorize]
	before_action :admin_users, only: [:destroy, :block]
	
	def create
		@obj = current_user.cards.new(user_params)

		category_params.each { |cat_id|
			@obj.cc_relations.build(category_id:cat_id)
		}

		if @obj.save
			flash[:success] = "Карточка создана"
			redirect_to card_path(@obj)
		else
			flash.now[:error] = 'ОШИБКА, карточка не создана'
			render 'new'
		end
	end

	def update
		card = Card.find_by(id: params[:id])
		card.categorize(category_params)
		#puts "=====> #update, card.cat_ids: #{card.cat_ids}"
		super(card)
	end

	private	

		def user_params
			params.require(:card).permit(
				:title,
				:content,
			)
		end

		def category_params
			#puts "====== category_params ======> params[:categories]: #{params[:categories]}(#{params[:categories].class})"

			if params[:categories].is_a?(Array)
				the_params = params.require(:categories)
				#puts "====== category_params ======> .require: #{the_params}(#{the_params.class})"

				the_params.reject! {|item| !item.is_a?(String)}
				#puts "====== category_params ======> .reject! (1): #{the_params}(#{the_params.class})"

				the_params.reject! {|item| item.to_i.to_s != item}
				#puts "====== category_params ======> .reject! (2): #{the_params}(#{the_params.class})"
				
				the_params.map! {|item| item.to_s}
				#puts "====== category_params ======> .map!: #{the_params}(#{the_params.class})"
				
				the_params.uniq!
				#puts "====== category_params ======> .uniq!: #{the_params}(#{the_params.class})"
			else
				the_params = nil
			end

			# если в результате список схлопнулся
			the_params = nil if the_params.to_s.empty?
			#puts "====== category_params ======> final: #{the_params}(#{the_params.class})"

			return the_params
		end

		def editor_users
			@obj = Card.find_by(id: params[:id])

			if (current_user != @obj.user) && (not current_user.admin?)
				flash[:error] = 'Редактирование запрещено'
				redirect_to card_path(@obj)
			end
		end
end

