module ApplicationHelper
	def full_title(title)
		title = '*нет заголовка*' if title.blank?
		base_title = '☯ Соционический каталог'
		base_title + ': ' + title
	end

	def card_id(id)
		"card#{id}"
	end

	def url_for_password_reset(arg)
		url_for(
			host:'localhost',
			port: 3000,
			controller: 'users',
			action: 'reset_response'
		) + "?reset_code=#{arg[:reset_code]}"
	end
end
