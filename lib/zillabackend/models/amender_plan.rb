module ZillaBackend
	class Models::AmenderPlan
		attr_accessor :id, :name, :description, :product_name, :amendment_type, :amendment_id, :uom, :quantity, :amender_charges, :effective_date

		def initialize
			self.amender_charges = Array.new
		end
	end
end