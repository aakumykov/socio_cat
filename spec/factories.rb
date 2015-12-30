FactoryGirl.define do
	#ActionView::Helpers::TextHelper

	factory :card do
		title Faker::Lorem.word.capitalize
		content Faker::Lorem.paragraph
		user
	end

	factory :user do
		name                  { Faker::Name.first_name }
		email                 { Faker::Internet.email }
		password              'Password123$%^'
		password_confirmation 'Password123$%^'

		factory :admin do
			admin true
		end
	end

	# factory :category do
	# 	name { truncate(Faker::Lorem.word.capitalize, length: 10, separator: ' ') }
	# 	description { truncate(Faker::Lorem.paragraph, length: 120, separator: ' ') }
	# 	#user
	# end
end
