module ZillaBackend
	class Catalog
		attr_accessor :last_sync

		def self.refresh_cache
			
			Zuora.configure(username: Config.username, password: Config.pass, sandbox: Config.sandbox, logger: Config.logger)

			where_str = "EffectiveStartDate<'"+DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")+"' and EffectiveEndDate>'"+DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")+"'"
			products = Zuora::Objects::Product.where(where_str)
			
			catalog_products = Array.new
			#setup the catalog_product objects
			products.each do |p|
				catalog_product = ZillaBackend::Models::CatalogProduct.new
				catalog_product.id = p.id
				catalog_product.name = p.name
				catalog_product.description = p.description ||= ""
				#get rate plans for this product
				rate_plan_where = "ProductId='" + catalog_product.id + "' and EffectiveStartDate<'"+DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")+"' and EffectiveEndDate>'"+DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")+"' "
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
  			write_to_cache catalog_products
  			return read_from_cache
		end
		#write the catalog_products to the cache
		def self.write_to_cache(input)
			File.open(Config.cache_path, 'w') {|f| f.write(input.to_json) }
		end
		#read the catalog from the cache
		def self.read_from_cache
			json = File.read(Config.cache_path)
			catalog_products = JSON.parse(json)
		end
		#get a rate plan from the cache given a rate plan id
		def self.get_rate_plan(id)
			catalog_products = read_from_cache
			catalog_products.each do |p|
				p["rate_plans"].each do |rp|
					if rp["id"] == id
						return rp
					end
				end
			end
		end
	end


end