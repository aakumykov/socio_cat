namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		make_cards
	end
end

def make_cards
	10.times do
		Card.create!(
			title: Faker::Lorem.word.capitalize,
			content: Faker::Lorem.paragraph,
		)
	end
end

