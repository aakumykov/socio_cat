FactoryGirl.define do
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

	factory :category do
		name { Faker::Lorem.word.capitalize }
		description { Faker::Lorem.paragraph }
		user
	end
end
