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
	def hash_for_checkboxes(categories_list=[])
		#puts "===== hash_for_checkboxes =====> categories_list: #{categories_list}"

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
end
