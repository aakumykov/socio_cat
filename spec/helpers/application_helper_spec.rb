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
end