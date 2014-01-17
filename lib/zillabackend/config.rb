module ZillaBackend
	#
	#Holds all the config in a hash and sets some default values
	#
	 puts Dir.pwd 
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
				defaults[:default_payment_term] = "Due Upon Receipt"
				defaults[:default_batch] = "Batch1"
				defaults[:default_country] = "USA"
				defaults[:default_state] = "CA"

				defaults[:make_sfdc_account] = false

				#HPM Info
				defaults[:page_id] = '2c92c0f93a3055aa013a438f86cb5bcd'
				defaults[:tenant_id] = 10717
				defaults[:api_security_key] = 'Y46yy3LMIBRIeqwzk_u4-4YvBGU_HHs79PCHcoihq90='
				defaults[:app_url] = 'https://apisandbox.zuora.com'

				update!(defaults)
		end
	end
end
