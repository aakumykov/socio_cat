
# RSpec::Matchers.define :have_button do |value|
# 	match do |actual|
# 		expect(actual).to have_selector(:xpath,"//input[@type='submit' and @value='#{value}']")
# 	end
# end

RSpec::Matchers.define :have_button do |type,value|
	match do |actual|
		expect(actual).to have_selector(:xpath,"//input[@type='#{type}' and @value='#{value}']")
	end
end