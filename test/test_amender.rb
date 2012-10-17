require 'helper'

class AmenderTest < Test::Unit::TestCase
	include ZillaBackendTestHelper

	def test_add_rate_plan
		sub_res = create_test_subscribe
		acc_res = Zuora::Objects::Account.where(account_number: sub_res[:account_number])
		account_name = acc_res[0].name
		prp_id = get_product_rate_plan_id
		qty = 1
		preview = false

		actually = ZillaBackend::Amender.add_rate_plan(account_name, prp_id, qty, preview)
		assert_equal actually[:success], true

		clear_test_stuff
	end

	def test_remove_rate_plan
		sub_res = create_test_subscribe
		acc_res = Zuora::Objects::Account.where(account_number: sub_res[:account_number])
		account_name = acc_res[0].name
		rp_id = Zuora::Objects::RatePlan.where(subscription_id: sub_res[:subscription_id])[0].id
		qty = 1
		preview = false
		
		actually = ZillaBackend::Amender.remove_rate_plan(account_name, rp_id, preview)
		assert_equal actually[:success], true

		clear_test_stuff
	end
end