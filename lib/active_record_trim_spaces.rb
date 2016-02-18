module ActiveRecordTrimSpaces
	extend ActiveSupport::Concern

	protected
		def remove_trailing_spaces(*attr_list)
			attr_list.map!{|i| i.to_s}
			
			self.attributes.each_pair {|k,v|
				if not v.nil?
					self.assign_attributes(k => v.strip) if attr_list.include?(k)
				end
			}
		end
end

ActiveRecord::Base.send(:include, ActiveRecordTrimSpaces)
