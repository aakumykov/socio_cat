module ActiveRecordTrimSpaces
	extend ActiveSupport::Concern

	protected
		def rts
			self.attributes.each_pair {|k,v|
				self.assign_attributes(k => v.strip) if v.is_a?(String)
			}
		end
end

ActiveRecord::Base.send(:include, ActiveRecordTrimSpaces)
