class CcRelation < ActiveRecord::Base
	belongs_to :category
	belongs_to :card

	#validates :category_id, numericality: { only_integer: true }
	#validates :card_id, numericality: { only_integer: true }
end
