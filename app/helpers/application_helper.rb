module ApplicationHelper
	def full_title(title)
		title = '*нет заголовка*' if title.blank?
		base_title = '☯ Соционический каталог'
		base_title + ': ' + title
	end
	
	def card_id(id)
		"card#{id}"
	end

	def my_sanitize(text)
		sanitize(
			simple_format(text,{},{sanitize:false}),
			tags: ['p','div','b','i','s','u','br'],
		)
	end
end
