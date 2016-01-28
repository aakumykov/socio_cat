namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		create_admin_user
		create_users
		create_cards
		create_categoties
	end
end

def create_users
	User.create!(
		name: 'Демьян',
		email: 'debian@linux.com',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
	)
	User.create!(
		name: 'Убунту',
		email: 'ubuntu@linux.com',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
	)
	User.create!(
		name: 'Андрей',
		email: 'aakumykov@yandex.ru',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
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
	2.times do
		Card.create!(
			title: Faker::Lorem.word.capitalize,
			content: Faker::Lorem.paragraph,
			user: User.where(admin:false).first,
		)
	end

	2.times do
		Card.create!(
			title: Faker::Lorem.word.capitalize,
			content: Faker::Lorem.paragraph,
			user: User.where(admin:false).last,
		)
	end
end

def create_categoties
	4.times do
		Category.create!(
			name: Faker::Lorem.word.capitalize,
			description: Faker::Lorem.paragraph,
			#user: User.where(admin:true).first,
		)
	end
end