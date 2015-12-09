module ApplicationHelper
	def full_title(title)
		title = '*нет заголовка*' if title.blank?
		base_title = 'SocioCat'
		base_title + ': ' + title
	end
	def card_id(id)
		"card#{id}"
	end
end
