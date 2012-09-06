require 'helper'


class CartTest < Test::Unit::TestCase
	include ZillaBackendTestHelper

	def test_create_new_cart
		actually = ZillaBackend::Cart.new
		assert_not_equal actually, nil
	end

	def test_cart_item
		actually = ZillaBackend::Models.CartItem.new
		assert_not_equal actually, nil
	end
end