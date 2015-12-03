FactoryGirl.define do
	factory :card do
		title 'Какой-то заголовок'
		content 'Некое содержимое. Правда-правда, это некоторое содержимое. Очень странное, но очень настоящее содержимое.'
	end

	factory :user do
		name Faker::Name
		email Faker::Internet.email
	end
end
