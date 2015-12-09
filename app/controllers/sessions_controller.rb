class SessionsController < ApplicationController
	def new
		@user = User.new
	end
end

private

	def user_params
		params.require(:session).permit(
			:email,
			:password,
		)
	end