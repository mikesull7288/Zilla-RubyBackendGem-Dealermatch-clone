require 'helper'

class SubscriptionManagerTest < Test::Unit::TestCase
	include ZillaBackendTestHelper
	
	def test_preview_non_empty_cart
		#add a cart item
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][0]["rate_plans"][0]["id"]
		cart = ZillaBackend::Cart.new
		cart.add_cart_item(rate_plan_id, 2)

		#preview the subscribe call
		actually = ZillaBackend::SubscriptionManager.preview_cart(cart)
		assert_equal actually.success, true
	end

	def test_preview_empty_or_nil_cart
		actually = ZillaBackend::SubscriptionManager.preview_cart(nil)
		assert_equal actually.error, "EMPTY_CART"
	end

	def test_subscribe_preview_model
		actually = ZillaBackend::Models::SubscribePreview.new
		assert_not_equal actually, nil
	end
end