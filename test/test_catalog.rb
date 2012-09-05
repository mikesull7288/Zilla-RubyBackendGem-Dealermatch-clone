require 'helper'


class CatalogTest < Test::Unit::TestCase
	include ZillaBackendTestHelper

	def test_zuora_api_works
		Zuora.configure(username: "smogger914@yahoo.com", password: "Fo!d3168", sandbox: true, logger: false)
		accs = Zuora::Objects::Account.all
	end

	def test_refresh_catalog		
		actually = ZillaBackend::Catalog.refresh_cache()
		assert_equal actually, true
	end

	#make sure the models exist
	def test_new_catalog_group
		actually = ZillaBackend::Models::CatalogGroup.new
		assert_not_equal actually, nil
	end

	def test_new_catalog_product
		actually = ZillaBackend::Models::CatalogProduct.new
		assert_not_equal actually, nil
	end

	def test_new_catalog_rate_plan
		actually = ZillaBackend::Models::CatalogRateplan.new
		assert_not_equal actually, nil
	end
	def test_new_catalog_charge
		actually = ZillaBackend::Models::CatalogCharge.new
		assert_not_equal actually, nil
	end
end