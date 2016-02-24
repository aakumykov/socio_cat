class CardsController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	before_action :signed_in_users, only: [:new, :create, :edit, :update]
	before_action :editor_users, only: [:edit, :update]
	before_action :admin_users, only: [:destroy, :block]
	
	def new
		@obj = Card.new(kind:params.fetch(:kind,'draft'))
		@checkboxes = hash_for_checkboxes
	end

	def create
		@obj = current_user.cards.new(card_params)

		# if !card_params[:new_category].blank?
		# 	@new_category = Category.create(name: card_params[:new_category])

		# 	if @new_category.reload
		# 		flash[:success] = "Создана категория «{card_params[:new_category]}»"
		# 		params[:categories] << @new_category.reload.id
		# 	else
		# 		flash[:danger] = "Ошибка создания категории «{card_params[:new_category]}» #{@new_category.errors.full_messages}"
		# 	end
		# end

		if @obj.save
			@obj.fill_categories(category_params)
			flash[:success] = "Создана карточка «#{@obj.title}»"

			if !card_params[:new_category].blank?
				@new_category = @obj.categories.create(name: card_params[:new_category])
				
				if @new_category.save
					@new_category = @obj.categories.last
					flash[:success] = "Создана категория «#{@new_category.name}». #{flash[:success]}"
				else
					flash[:danger] = "Ошибка создания категории «#{card_params[:new_category]}»: #{@new_category.errors.full_messages}"
				end
			end

			redirect_to card_path(@obj)
		else
			#flash.now[:danger] = 'ОШИБКА, карточка не создана'
			@checkboxes = hash_for_checkboxes(category_params)
			render 'new'
		end
	end

	def edit
		super
		@checkboxes = hash_for_checkboxes(@obj.categories)
	end

	def update
		@obj = Card.find_by(id: params[:id])
		
		if @obj.update_attributes(card_params)
			@obj.fill_categories(category_params)
			flash[:success] = "Изменения сохранены"
			redirect_to @obj
		else
			#flash.now[:danger] = "Изменения отклонены"
			@checkboxes = hash_for_checkboxes(category_params)
			render :edit
		end
	end

	def chtype(new_type)
		@card = Card.new(card_params)

		if @card
			redirect_to new_card_path
		else
			flash.now[:danger] = 'Ошибка смены типа карточки'
			render :edit
		end
	end

	private	

		def card_params
			params.require(:card).permit(
				:kind,
				:title,
				:description,
				:new_category,
				:text,
				:image,
				:audio,
				:video,
			)
		end

		def category_params
			puts "====== category_params ======> params[:categories]: #{params[:categories]}(#{params[:categories].class})"

			if !params[:categories].nil? && params[:categories].is_a?(Array)
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
			the_params = [] if the_params.to_s.empty?

			#puts "====== category_params ======> final: #{the_params}(#{the_params.class})"

			return the_params
		end


		def editor_users
			@obj = Card.find_by(id: params[:id])

			if (current_user != @obj.user) && (not current_user.admin?)
				flash[:danger] = 'Редактирование запрещено'
				redirect_to card_path(@obj)
			end
		end
end

