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
end
