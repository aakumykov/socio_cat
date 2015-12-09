require 'spec_helper'

describe ApplicationHelper do

	describe 'full_title' do
		let(:base_title) {'SocioCat: '}
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
end
