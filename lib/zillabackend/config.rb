module ZillaBackend
	class Config
		def self.initialize(data={})
     	 	@data = {}
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
	end
end