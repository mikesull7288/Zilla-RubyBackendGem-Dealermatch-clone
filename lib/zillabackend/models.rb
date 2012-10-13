module ZillaBackend
	module Models
		autoload :CatalogGroup, 'zillabackend/models/catalog_group'
		autoload :CatalogProduct, 'zillabackend/models/catalog_product'
		autoload :CatalogRateplan, 'zillabackend/models/catalog_rateplan'
		autoload :CatalogCharge, 'zillabackend/models/catalog_charge'
		autoload :CartCharge, 'zillabackend/models/cart_charge'
		autoload :CartItem, 'zillabackend/models/cart_item'	
		autoload :SubscribePreview, 'zillabackend/models/subscribe_preview'
		autoload :SummaryContact, 'zillabackend/models/summary_contact'
		autoload :AmenderSubscription, 'zillabackend/models/amender_subscription'	
		autoload :AmenderPlan, 'zillabackend/models/amender_plan'	
		autoload :AmenderCharge, 'zillabackend/models/amender_charge'	
	end
end