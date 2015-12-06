class PasswordStrenthValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		patterns = [
			/[[:lower:]]/,
			/[[:upper:]]/,
			/[[:digit:]]/,
			/[!@#$%^&*()_+=\-`~'"|\/\\;:.,№? ]/
		]
		
		format_is_bad = false
		
		if not value.nil?
			patterns.each do |regex|
				value.match(regex) or format_is_bad = true
			end
		end

		if format_is_bad
			record.errors[attribute] << (options[:message] || 'is not complex enough')
		end
	end
end