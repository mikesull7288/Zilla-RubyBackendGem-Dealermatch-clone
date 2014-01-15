module ZillaBackend
	class Models::CatalogRateplan
		attr_accessor :id, :name, :product_name, :description, :quantifiable, :uom, :charges, :self_signup_price__c
	end
end