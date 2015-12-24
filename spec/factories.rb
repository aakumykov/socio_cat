FactoryGirl.define do
	factory :card do
		title 'Какой-то заголовок'
		content 'Некое содержимое. Правда-правда, это некоторое содержимое. Очень странное, но очень настоящее содержимое.'
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
end
