class MattersController < ApplicationController

	before_action :reject_nil_target, only: [:show, :edit, :update, :destroy]
	#before_action :signed_in_users, only: []
	#before_action :editor_users, only: []
	before_action :admin_users, only: [:new, :create, :edit, :update, :destroy, :block]


	def index
		@list = Matter.all
	end

	def new
		@obj = Matter.new
	end

	def create
		@obj = Matter.new(matter_params)
		if @obj.save
			flash[:success] = "Создан объект «#{@obj.name}»"
			redirect_to matter_path @obj
		else
			render :edit
		end
	end

	def show
		@obj = Matter.find_by(id: params[:id])
	end

	def edit
		@obj = Matter.find_by(id: params[:id])
	end

	def update
		@obj = Matter.find_by(id: params[:id])

		if @obj.update_attributes(matter_params)
			flash[:success] = "Объект «#{@obj.name}» изменён"
			redirect_to @obj
		else
			render :edit
		end
	end

	def destroy
		@obj = Matter.find_by(id: params[:id])

		if @obj.destroy
			flash[:notice] = "Удалён объект «#{@obj.name}»"
			redirect_to matters_path
		else
			flash[:danger] = "Ошибка удаления «#{@obj.name}»"
			redirect_to @obj
		end
	end

	private
		def matter_params
			params.require(:matter).permit(:name)
		end
end
