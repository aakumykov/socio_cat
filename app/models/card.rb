class Card < ActiveRecord::Base

	belongs_to :user, inverse_of: :cards
	#validates_associated :user
	
	has_and_belongs_to_many :categories
	#validates_associated :categories


	before_validation { |m| m.remove_trailing_spaces(:title,:content) }
	after_save :categorize


	validates :title, {
		presence: true,
		length: { maximum: 80 }
	}
	
	validates :content, {
		presence: true,
		length: { maximum: 1000 }
	}

	validates :user_id, {
		presence: true,
		format: /\A[0-9]+\z/,
	}

	def categorize(cat_id_list=nil)
		#puts "=========> cat_id_list: |#{cat_id_list}|"

		if cat_id_list.is_a?(Array) && !cat_id_list.compact.empty?
			# удаляю то, что не даёт цифровой id
			cat_id_list.reject! {|i| !i.respond_to?(:id) && !i.respond_to?(:to_i)}
			#puts "==========> cat_id_list.reject!: #{cat_id_list}"
			
			cat_id_list.map! {|i| i.respond_to?(:id) && i.id or i}
			cat_id_list.map! {|i| i.respond_to?(:to_i) && i.to_i or i}
			#puts "==========> cat_id_list.map!: #{cat_id_list}"

			return false if cat_id_list.empty?

			current_cat_ids = Category.where(id:cat_id_list).pluck(:id)
			#puts "==========> current_cat_ids: #{current_cat_ids}"

			all_cat_ids = cat_id_list.concat(current_cat_ids).map!{|i| i.to_i}.uniq!
			#puts "==========> all_cat_ids: #{all_cat_ids}"

			new_cats = Category.find(all_cat_ids)
			self.categories.concat(new_cats)
		end
	end
end
