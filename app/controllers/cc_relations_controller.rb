class CcRelationsController < ApplicationController
	
	#before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	#before_action :not_signed_in_users, only: [:new, :create]
	#before_action :signed_in_users, only: [:show, :edit, :update]
	before_action :editor_users, only: [:bind]
	before_action :admin_users, only: [:unbind]

	def bind
		@card = Card.find_by(id: params[:card_id])
		@category = Category.find_by(id: params[:category_id])

		# if @card.nil? && !@category.nil?
			
		# 	flash[:error] = "Такой карточки не существует"
		# 	redirect_to cards_path

		# elsif !@card.nil? && @category.nil?
			
		# 	flash[:error] = "Такой категории не существует"
		# 	redirect_to card_path(@card)

		# elsif @card.nil? && @category.nil?
			
		# 	flash[:error] = "Несуществующие карточка и категория"
		# 	redirect_to root_path

		# else
		# 	if @category.cards.include(@card)
		# 		flah[:warning] = "Категория уже назначена"
		# 		redirect_to card_path(@card)
		# 	else
		# 		if @category.cards << @card
		# 			flash[:success] = "Назначена категория «#{@category.name}»"
		# 		else
		# 			flash[:error] = "Ошибка"
		# 		end
		# 		redirect_to card_path(@card)
		# 	end
		# end

		if @category.cc_relations.create(@card)
			flash[:success] = "Назначена категория «#{@category.name}»"
		else
			flash[:error] = "Ошибка назначения категории «#{@category.name}»"
		end
		redirect_to card_path(@card)
	end

	def unbind
		@cc_relation = CcRelation.find_by(id: params[:id])
		if @cc_relation.nil?
			flash[:error] = "Такой связи не существует"
			redirect_to cards_path
		else
			@cc_relation.destroy
			
			@card = @cc_relation.card
			@category = @cc_relation.category
			
			flash[:success] = "Карточка «#{@card.title}» удалена из категории «#{@category.name}»"
			
			redirect_to card_path(@card)
		end
	end
end
