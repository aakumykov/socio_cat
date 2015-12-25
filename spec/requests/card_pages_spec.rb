require 'spec_helper'

describe 'Стриницы карточек,' do
	let(:user) { FactoryGirl.create(:user) }
	let(:admin) { FactoryGirl.create(:user) }

	let(:create_button) { 'Создать' }
	let(:change_button) { 'Изменить' }
	let(:save_button) { 'Сохранить' }
	let(:cancel_button) { 'Отмена' }

	pending 'предфильтры' do
		pending 'reject_nil_target()'
		pending 'signed_in_users()'
		pending 'editor_users()'
		pending 'admin_users()'
	end

	pending 'список,'
	pending 'просмотр,'
	pending 'создание,'
	pending 'изменение,'
	pending 'удаление,'
end