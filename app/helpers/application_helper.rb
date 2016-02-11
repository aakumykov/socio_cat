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

	# Превращает массив категорий карточки в массив всех
	# категорий, в котором помечены категории этой карточки.
	#
	# Принимает: массив категорий карточки
	# Возвращает: массив вида
	# 	[
	# 		{ name: 'Аналитик', id: 8, checked: true },
	# 		{ name: 'Искатель', id: 7, checked: false },
	#   ]
	#
	# Который удобно использовать при построении формы с галочками
	#
	def hash_for_checkboxes(categories_list=nil)
		#puts "===== hash_for_checkboxes =====> categories_list.class: #{categories_list.class}"
		#puts "===== hash_for_checkboxes =====> categories_list.respond_to?: #{categories_list.respond_to?(:pluck)}"

		if categories_list.is_a?(Array)
			#puts "===== hash_for_checkboxes =====> case1"
			true
		elsif categories_list.respond_to?(:pluck)
			#puts "===== hash_for_checkboxes =====> case2"
			categories_list = categories_list.pluck(:id)
		else
			#puts "===== hash_for_checkboxes =====> case3"
			categories_list = []
		end

		all_cats = Hash.new
		
		# получаю словарь категорий
		Category.all.map { |c|
			all_cats[c.id] = {
				name: c.name,
				checked: false,
			}
		}

		# отмечаю используемые
		categories_list.each { |id|
			id = id.to_i
			#puts "===== all_cats[#{id}] =====> #{all_cats[id]}"
			all_cats[id][:checked] = true if not all_cats[id].nil?
		}

		#puts "===== hash_for_checkboxes =====> all_cats: #{all_cats}"
		return all_cats
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



