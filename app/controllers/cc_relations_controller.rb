class CcRelationsController < ApplicationController
	
	#before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	#before_action :not_signed_in_users, only: [:new, :create]
	#before_action :signed_in_users, only: [:bind, :unbind]
	#before_action :editor_users, only: [:bind]
	before_action :admin_users, only: [:bind, :unbind]

	def bind
		@card = Card.find_by(id: params[:card_id])
		@category = Category.find_by(id: params[:category_id])

		if @category.cc_relations.create(@card)
			flash[:success] = "Назначена категория «#{@category.name}»"
		else
			flash[:danger] = "Ошибка назначения категории «#{@category.name}»"
		end
		redirect_to card_path(@card)
	end

	def unbind
		@cc_relation = CcRelation.find_by(category_id: params[:category_id], card_id: params[:card_id])
		if @cc_relation.nil?
			flash[:danger] = "Такой связи не существует"
			redirect_to cards_path
		else
			@cc_relation.destroy
			
			@card = @cc_relation.card
			@category = @cc_relation.category
			
			flash[:success] = "Карточка «#{@card.title}» удалена из категории «#{@category.name}»"
			
			redirect_to card_path(@card)
		end
	end

	private
		def admin_users
			if !current_user || !current_user.admin?
				flash[:danger] = 'Доступно только администратору'
				redirect_to url_for(
					controller: 'cards',
					action: 'show',
					id: params[:card_id]
				)
			end
		end
end
