module ApplicationHelper
	def full_title(title)
		title = '*нет заголовка*' if title.blank?
		base_title = '☯ Соционический каталог'
		base_title + ': ' + title
	end

	def card_id(id)
		"card#{id}"
	end

	def password_reset_url(arg)
		url_for(
			host:'localhost',
			controller: 'users',
			action: 'reset_response'
		) + "?code=#{arg[:code]}"
	end
end
