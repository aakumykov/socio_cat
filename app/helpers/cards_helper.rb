module CardsHelper
	def show_content(card)
		value = card.content(card.kind)

		case card.kind
		when 'текст'
			render 'cards/content/display/text', value:value
		when 'картинка'
			render 'cards/content/display/image', value:value
		when 'музыка'
			render 'cards/content/display/audio', value:value
		when 'видео'
			render 'cards/content/display/video', value:value
		else
			render 'cards/content/display/unknown'
		end
	end

	def card_badge(kind)
		case kind
		when 'текст'
			'badge_text'
		when 'картинка'
			'badge_image'
		when 'музыка'
			'badge_audio'
		when 'видео'
			'badge_video'
		else
			'bagde_unknown'
		end
	end
end
