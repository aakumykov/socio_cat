module SessionsHelper
	
	def sign_in(user)
		remember_token = User.new_remember_token
		
		#save_referer
		cookies.permanent[:remember_token] = remember_token
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		
		self.current_user = user
	end

	def sign_out
		current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
		#save_referer
		cookies.delete(:remember_token)
		self.current_user = nil
	end

	def signed_in?
		!current_user.nil?
	end


	def current_user
		remember_token = User.encrypt(cookies[:remember_token])
		@current_user ||= User.find_by(remember_token: remember_token)
	end

	def current_user?(user)
		current_user == user
	end

	def current_user=(user)
		@current_user = user		
	end


	def save_referer
		referer = request.referer.blank? ? root_url : request.referer
		cookies[:referer] = referer
	end

	def redirect_back
		uri = URI(cookies[:referer])
		if uri.host != request.host
			referer = "#{request.host}:#{request.port}"
		else
			referer = uri.to_s
		end
		redirect_to referer
		cookies.delete :referer
	end
end
