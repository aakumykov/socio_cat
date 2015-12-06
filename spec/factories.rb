FactoryGirl.define do
	factory :card do
		title 'Какой-то заголовок'
		content 'Некое содержимое. Правда-правда, это некоторое содержимое. Очень странное, но очень настоящее содержимое.'
	end

	# factory :user do		
	# 	name Faker::Name
	# 	email Faker::Internet.email
	# 	password 'Password123$%^'
	# 	password_confirmation 'Password123$%^'
	# end

	factory :user do
		sequence(:name)  { |n| "Пользователь #{n}" }
		sequence(:email) { |n| "user_#{n}@example.com"}
		password 'Password123$%^'
		password_confirmation 'Password123$%^'

		# factory :admin do
		# 	admin true
		# end
	end
end
