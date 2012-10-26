require 'helper'

class SubscriptionManagerTest < Test::Unit::TestCase
	include ZillaBackendTestHelper
	
	def test_get_current_subscription
		actually = ZillaBackend::SubscriptionManager.get_current_subscription("123")
		assert_not_equal actually, nil
	end

	def test_bad_subscribe_inputs_should_return_different_errors
		#add a cart item
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][0]["rate_plans"][0]["id"]
		cart = ZillaBackend::Cart.new
		cart.add_cart_item(rate_plan_id, 2)

		actually = ZillaBackend::SubscriptionManager.subscribe_with_current_cart(nil, nil, nil)
		assert_equal actually, "CART_NOT_INITIALIZED"
		
		actually = ZillaBackend::SubscriptionManager.subscribe_with_current_cart(nil,  nil, cart)
		assert_equal actually, "USER_EMAIL_NOT_PROVIDED"

		actually = ZillaBackend::SubscriptionManager.subscribe_with_current_cart("123@123.com", nil , cart)
		assert_equal actually, "INVALID_PMID"
	end

	def test_subscribe_non_empty_cart
		#valid payment id from hpm
		hpm_payment_id = '2c92c0f83a49193b013a530046103d5a'
		#add a cart item
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][1]["rate_plans"][0]["id"]
		cart = ZillaBackend::Cart.new
		cart.add_cart_item(rate_plan_id, 2)

		actually = ZillaBackend::SubscriptionManager.subscribe_with_current_cart("12345@123.com", hpm_payment_id, cart)
		
		assert_equal actually[:success] == nil ? actually : actually[:success], true
	end

	def test_preview_non_empty_cart
		#add a cart item
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][1]["rate_plans"][0]["id"]
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

	def test_amender_subscription_model
		actually = ZillaBackend::Models::AmenderSubscription.new
		assert_not_equal actually, nil
	end

	def test_amender_plan_model
		actually = ZillaBackend::Models::AmenderPlan.new
		assert_not_equal actually, nil
	end

	def test_amender_charge_model
		actually = ZillaBackend::Models::AmenderCharge.new
		assert_not_equal actually, nil
	end
end