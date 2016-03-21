namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do
		require 'factory_girl'
		require Rails.root.join('spec/factories')
		
		create_admin_user
		create_users
		create_matters
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
		activated: true,
	)
	User.create!(
		name: 'Убунту',
		email: 'ubuntu@linux.com',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
		activated: true,
	)
	User.create!(
		name: 'Андрей',
		email: 'aakumykov@yandex.ru',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
		activated: true,
		admin: true,
	)
end

def create_admin_user
	User.create!(
		name: 'Админ',
		email: 'admin@example.com',
		password: 'Qwerty123!@#',
		password_confirmation: 'Qwerty123!@#',
		admin: true,
		activated: true,
	)
end

def create_matters
	2.times do
		Matter.create!(
			name: Faker::Lorem.word
		)
	end
end

def create_cards
	2.times do
		FactoryGirl.create(
			:card, 
			user: User.where(admin:false).first,
			matter: Matter.first,
		)
	end

	2.times do
		FactoryGirl.create(
			:card, 
			user: User.where(admin:false).last,
			matter: Matter.last,
		)
	end
end

def create_categoties
	4.times do
		FactoryGirl.create(:category)
	end
end