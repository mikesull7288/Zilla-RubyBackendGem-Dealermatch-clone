module ZillaBackend
	class Config
		def self.initialize(data={})
     	 	@data = {}
      		update!(data)
      		set_defaults
		end

		def self.update!(data)
      		data.each do |key, value|
        		self[key] = value
      		end
    	end
    	
    	def self.[](key)
      		@data[key.to_sym]
    	end

	    def self.[]=(key, value)
	      	if value.kind_of?(Hash)
	        	@data[key.to_sym] = Config.new(value)
	      	else
	       		@data[key.to_sym] = value
	      	end
	    end

	    def self.method_missing(sym, *args)
	      	if sym.to_s =~ /(.+)=$/
	        	self[$1] = args.first
	      	else
	       		self[sym]
	     	end
	    end
	    
	    def self.set_defaults
	    	defaults = Hash.new
			defaults[:show_all_products] = false
			defaults[:grouping_field] = "zillacloudcompay__c"
			
			defaults[:grouping_field_values] = Array.new
			defaults[:grouping_field_values] << "Base Product"
			defaults[:grouping_field_values] << "Add-On Product"

			defaults[:cache_path] = "product_cache.txt"

			update!(defaults)
		end
	end
end