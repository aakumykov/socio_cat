module ApplicationHelper
	def full_title(title)
		title = '*нет заголовка*' if title.blank?
		base_title = '☯ Соционический каталог'
		base_title + ': ' + title
	end

	def card_id(id)
		"card#{id}"
	end

	def url_for_password_reset(opt = {mode:'url'})
		url = reset_response_path + "?reset_code=#{opt[:reset_code]}"
		#url_for(controller: 'users', action: 'reset_response')
		
		if 'url'==opt[:mode].to_s
			url = "http://localhost:3000" + url
		end
		
		#puts "===== reset_response_path ====> #{reset_response_path}"
		#puts "===== reset_response_url ====> #{reset_response_url(host:'localhost',port:3000)}"
		
		return url
	end
end
