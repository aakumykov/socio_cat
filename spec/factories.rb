FactoryGirl.define do
	#ActionView::Helpers::TextHelper

	factory :card do
		title Faker::Lorem.word.capitalize
		content Faker::Lorem.paragraph
		user
	end

	factory :user do
		name                  { Faker::Name.first_name + "_#{rand(1..100)}" }
		email                 { Faker::Internet.email }
		password              'FactoryPass123$%^'
		password_confirmation 'FactoryPass123$%^'

		factory :admin do
			admin true
		end
	end

	factory :category do
		name { Faker::Lorem.word.capitalize * 2 } # иначе бывает слишком коротким
		description { Faker::Lorem.paragraph }
		#user
	end
end
