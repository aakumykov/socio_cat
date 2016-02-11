require 'spec_helper'

describe ApplicationHelper do

	describe 'full_title' do
		let(:base_title) {'☯ Соционический каталог: '}
		let(:title) {'раздел одну'}

		it 'должен включать базовый заголовок' do
			expect( full_title(title) ).to match("^#{base_title}")
		end

		it 'должен включать заголовок страницы' do
			expect( full_title(title) ).to match(": #{title}$")
		end
	end

	describe 'card_id' do
		let(:id) { 1 }
		it 'превращение цифры в сложный id' do
			expect(card_id(id)).to match(/\Acard#{id}\z/)
		end
	end

	describe 'url_for_password_reset(),' do
		let(:code) { User.new_remember_token }
		let(:query) { "?reset_code=#{code}" }
		let(:valid_path) { url_for(controller: 'users', action: 'reset_response', only_path:true) + query }
		let(:valid_url) { url_for(controller: 'users', action: 'reset_response') + query }

		context 'режим "url"' do
			specify{
				expect(url_for_password_reset(reset_code: code, mode: 'url')).to eq valid_url
			}
		end

		context 'режим по умолчанию' do
			specify{
				expect(url_for_password_reset(reset_code: code)).to eq valid_path
			}
		end
	end
end
