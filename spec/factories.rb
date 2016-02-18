FactoryGirl.define do
	#ActionView::Helpers::TextHelper

	factory :card do
		title { Faker::Lorem.word.capitalize + '_' + rand(1..100).to_s }
		description Faker::Lorem.paragraph
		text Faker::Lorem.paragraph
		image Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/images/stub.png", "image/jpg")
	end

	factory :user do
		name                  { Faker::Name.first_name + '_' + rand(1..100).to_s }
		email                 { Faker::Internet.email }
		password              'FactoryPass123$%^'
		password_confirmation 'FactoryPass123$%^'

		factory :admin do
			admin true
			activated true
		end
	end

	factory :category do
		# имя с защитой от повторов / недостаточной длины
		name { Faker::Lorem.word.capitalize*2 + rand(1..10).to_s }
		description { Faker::Lorem.paragraph }
	end
end
