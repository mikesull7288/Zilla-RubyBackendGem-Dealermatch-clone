module ZillaBackend
	class Cart
		attr_accessor :cart_items, :latest_item_id

		def initialize
			clear_cart
		end

		def clear_cart
			self.cart_items = Array.new
			self.latest_item_id = 1
		end

		def add_cart_item(rate_plan_id, quantity)
			self.clear_cart
			new_cart_item = ZillaBackend::Models::CartItem.new
			new_cart_item.rate_plan_id = rate_plan_id
			new_cart_item.quantity = quantity
			new_cart_item.item_id = self.latest_item_id
		#	self.latest_item_id += 1

			plan = ZillaBackend::Catalog.get_rate_plan rate_plan_id
			new_cart_item.uom = plan["uom"] ||= ''	
			new_cart_item.rate_plan_name = plan["name"] ||= 'Invalid Product'
			new_cart_item.product_name = plan["product_name"] ||= 'Invalid Product'				
			
			self.cart_items << new_cart_item
		end

		def remove_cart_item(item_id)
			index_to_delete = self.cart_items.index {|ci| ci.item_id == item_id}			
			if(index_to_delete != nil)
				self.cart_items.delete_at index_to_delete
			end
			self.cart_items
		end
	end
end
