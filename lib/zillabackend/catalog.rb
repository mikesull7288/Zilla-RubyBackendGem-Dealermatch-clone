module ZillaBackend
	#\brief The Catalog class manages and caches all Product data retrieved from the configured Zuora tenant
	class Catalog
		attr_accessor :last_sync
		#
	    #Reads the Product Catalog Data from Zuora and saves it to a JSON cache stored on the server to reduce load times. This method must be called each time the Product Catalog is changed in Zuora to ensure the catalog is not out of date for the user.
	  	#@return A model containing all necessary information needed to display the products and rate plans in the product catalog
	 	 #
		def self.refresh_cache
			#initialize the zuora libraries		
			Zuora.configure(username: Config.username, password: Config.pass, sandbox: Config.sandbox, logger: Config.logger)

			date = DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")
			#for each classification 
			field_groups = Array.new
			num_groups = 0
			if(Config.show_all_products)
				num_groups = 1
				field_groups << ''
			else
				num_groups = Config.grouping_field_values.length
				field_groups = Config.grouping_field_values
			end
			catalog_groups = Array.new
			#make the catalog groups for sorting purposes
			field_groups.each do |fg|
				catalog_group = ZillaBackend::Models::CatalogGroup.new
				catalog_group.name = fg
				catalog_group.products = Array.new
				#get all products
				where_str = "EffectiveStartDate<'"+date+"' and EffectiveEndDate>'"+date+"'"
				if(!Config.show_all_products)
					where = " AND " + Config.grouping_field + " = '" + fg + "'"
					where_str += where
				end
				products = Zuora::Objects::Product.where(where_str)	
				catalog_products = Array.new
				#setup the catalog_product objects
				products.each do |p|
					catalog_product = ZillaBackend::Models::CatalogProduct.new
					catalog_product.id = p.id
					catalog_product.name = p.name
					catalog_product.description = p.description ||= ""
					#get rate plans for this product
					rate_plan_where = "ProductId='" + catalog_product.id + "' and EffectiveStartDate<'"+date+"' and EffectiveEndDate>'"+date+"' "
					rate_plans = Zuora::Objects::ProductRatePlan.where(rate_plan_where)
					catalog_product.rate_plans = Array.new
					rate_plans.each do |rp|
						catalog_rate_plan = ZillaBackend::Models::CatalogRateplan.new
						catalog_rate_plan.id = rp.id
						catalog_rate_plan.name = rp.name
						catalog_rate_plan.product_name = p.name
						catalog_rate_plan.description = p.description ||= ""
						catalog_rate_plan.charges = Array.new
						plan_uom = ""
						quantifiable = false
						#get the charges for the rate plan
						rate_plan_charges = Zuora::Objects::ProductRatePlanCharge.where(product_rate_plan_id: rp.id)
						rate_plan_charges.each do |rpc|
							catalog_charge = ZillaBackend::Models::CatalogCharge.new
							catalog_charge.id = rpc.id
							catalog_charge.name = rpc.name
							catalog_charge.description = rpc.description ||= ""
							catalog_charge.charge_model = rpc.charge_model
							catalog_charge.charge_type = rpc.charge_type
							if(rpc.charge_type != "Usage" && (rpc.charge_model == "Per Unit Pricing" || rpc.charge_model == "Tiered Pricing" || rpc.charge_model == "Volume Pricing"))
								catalog_charge.uom = rpc.uom
								plan_uom = rpc.uom
								quantifiable = true
							end
							catalog_rate_plan.charges << catalog_charge
						end
						catalog_product.rate_plans << catalog_rate_plan
					end
					catalog_products << catalog_product
				end
				catalog_group.products = catalog_products
				catalog_groups << catalog_group
			end
  			write_to_cache catalog_groups
  			return read_from_cache
		end
		#write the catalog_products to the cache
		def self.write_to_cache(input)
			File.open(Config.cache_path, 'w') {|f| f.write(input.to_json) }
		end
		#
		#Reads the Product Catalog Data from the locally saved JSON cache. If no cache exists, this will refresh the catalog from Zuora first.
	 	#@return A model containing all necessary information needed to display the products and rate plans in the product catalog
	 	#
		def self.read_from_cache
			json = File.read(Config.cache_path)
			catalog_groups = JSON.parse(json)
		end
		#
	 	#Given a RatePlan ID, retrieves all rateplan information by searching through the cached catalog file
	 	#@return RatePlan model
	 	#
		def self.get_rate_plan(id)
			catalog_groups = read_from_cache
			catalog_groups.each do |cg|
				cg["products"].each do |p|
					p["rate_plans"].each do |rp|
						if rp["id"] == id
							return rp
						end
					end
				end
			end
		end
	end
end