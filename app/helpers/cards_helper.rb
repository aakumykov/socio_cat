module CardsHelper
	def show_content(type,value)
		case type
		when :text
			render 'cards/content/display/text', value:value
		when :image
			render 'cards/content/display/image', value:value
		when :audio
			render 'cards/content/display/audio', value:value
		when :video
			render 'cards/content/display/video', value:value
		else
			render 'cards/content/display/unknown'
		end
	end
end
