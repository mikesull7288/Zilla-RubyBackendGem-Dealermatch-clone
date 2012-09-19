require 'helper'

class CartTest < Test::Unit::TestCase
	include ZillaBackendTestHelper

	def test_add_new_cart_item
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][0]["rate_plans"][0]["id"]
		actually = ZillaBackend::Cart.new
		actually.add_cart_item(rate_plan_id, 1)
		assert_not_equal actually.cart_items[0].rate_plan_id, nil
		assert_equal actually.latest_item_id, 2
		actually.add_cart_item(rate_plan_id, 2)
		assert_not_equal actually.cart_items, nil


	end

	def test_remove_cart_item
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][0]["rate_plans"][0]["id"]
		actually = ZillaBackend::Cart.new
		actually.add_cart_item(rate_plan_id, 1)
		del_res = actually.remove_cart_item(1)
		
		assert_equal actually.cart_items.count, 0
	end

	def test_remove_cart_item_from_many
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][0]["rate_plans"][0]["id"]
		actually = ZillaBackend::Cart.new

		actually.add_cart_item(rate_plan_id, 1)
		actually.add_cart_item(rate_plan_id, 1)
		actually.add_cart_item(rate_plan_id, 1)
		assert_equal actually.cart_items.count, 3
		del_res = actually.remove_cart_item(2)
		assert_equal actually.cart_items.count, 2
		del_res = actually.remove_cart_item(1)
		assert_equal del_res, actually.cart_items
		assert_equal actually.cart_items.count, 1
		del_res = actually.remove_cart_item(2)
		assert_equal actually.cart_items.count, 1
		del_res = actually.remove_cart_item(3)
		assert_equal actually.cart_items.count, 0

	end

	def test_new_cart
		actually = ZillaBackend::Cart.new
		assert_equal actually.latest_item_id, 1
		assert_equal actually.cart_items, Array.new

	end
	def test_new_cart_item
		actually = ZillaBackend::Models::CartItem.new
		actually.rate_plan_name = "test"
		assert_not_equal actually, nil
		assert_equal actually.rate_plan_name, "test"
	end

	def test_new_cart_charge
		actually = ZillaBackend::Models::CartCharge.new
		actually.quantity = 1
		assert_not_equal actually, nil
		assert_equal actually.quantity, 1
	end
end