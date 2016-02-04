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
		case opt[:mode]
		when 'url'
			url = url_for(controller: 'users', action: 'reset_response')
		else
			url = url_for(controller: 'users', action: 'reset_response', only_path:true)
		end
			
		"#{url}?reset_code=#{opt[:reset_code]}"
	end
end
