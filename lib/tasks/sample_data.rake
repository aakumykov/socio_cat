namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		create_admin_user
		create_users
		create_cards
	end
end

def create_users
	User.create!(
		name: 'Демьян',
		email: 'debian@linux.com',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
		#admin: false,
	)
end

def create_admin_user
	User.create!(
		name: 'Админ',
		email: 'admin@example.com',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
		admin: true
	)
end

def create_cards
	5.times do
		Card.create!(
			title: Faker::Lorem.word.capitalize,
			content: Faker::Lorem.paragraph,
			user: User.where(admin:false).first,
		)
	end
end