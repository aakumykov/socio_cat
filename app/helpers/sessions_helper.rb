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
		cookies[:request_uri] = referer
	end

	def redirect_back
		orig_referer = cookies[:referer] || request.referer

		if orig_referer.nil?
			referer = about_path
		else
			uri = URI(orig_referer)

			# отклонение внешнего referer
			if uri.host != request.host
				referer = "#{request.host}:#{request.port}"
			else
				referer = uri.to_s
			end

			# защита от простого зацикливания
			if referer == cookies[:request_uri]
				referer = root_url
			end
		end

		redirect_to referer
		cookies.delete :referer
	end
end
