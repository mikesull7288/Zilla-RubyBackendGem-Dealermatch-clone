module ZillaBackend
	#
	#Holds all the config in a hash and sets some default values
	#
	class Config
		def self.initialize(data={})
     	 	@data = {}
      		set_defaults
      		update!(data)    		
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
			defaults[:show_all_products] = true
			defaults[:grouping_field] = "zillacloudcompany__c"
			
			defaults[:grouping_field_values] = Array.new
			defaults[:grouping_field_values] << "Base Product"
			defaults[:grouping_field_values] << "Add-On Product"

			defaults[:cache_path] = "product_cache.txt"

			defaults[:default_autopay] = true
			defaults[:default_currency] = "USD"
			defaults[:default_payment_term] = "Due Upon Reciept"
			defaults[:default_batch] = "Batch1"
			defaults[:deault_country] = "USA"
			defaults[:default_state] = "CA"

			defaults[:make_sfdc_account] = false
			#TODO
			#ADD HPM INFORMATION

			update!(defaults)
		end
	end
end