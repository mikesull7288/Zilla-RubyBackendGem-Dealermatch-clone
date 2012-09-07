require 'helper'


class CatalogTest < Test::Unit::TestCase
	include ZillaBackendTestHelper

	def test_get_rate_plan
		rateplanid = 
		actually = ZillaBackend::Catalog.get_rate_plan("4028e6963457a2a001345936b60d33fa")
		assert_not_equal actually["name"], nil
	end

	def test_load_from_cache
		actually = ZillaBackend::Catalog.read_from_cache
		assert_not_equal actually[0]["name"], nil
	end

	def test_refresh_catalog		
		actually = ZillaBackend::Catalog.refresh_cache
		assert_not_equal actually[0]["name"], nil
	end

	#make sure the related models exist
	def test_new_catalog_group
		actually = ZillaBackend::Models::CatalogGroup.new
		actually.name = "testgroup"
		assert_not_equal actually, nil
		assert_equal actually.name, "testgroup"
	end

	def test_new_catalog_product
		actually = ZillaBackend::Models::CatalogProduct.new
		actually.name = "testproduct"
		assert_not_equal actually, nil
		assert_equal actually.name, "testproduct"
	end

	def test_new_catalog_rate_plan
		actually = ZillaBackend::Models::CatalogRateplan.new
		actually.name = "testrateplan"
		assert_not_equal actually, nil
		assert_equal actually.name, "testrateplan"
	end

	def test_new_catalog_charge
		actually = ZillaBackend::Models::CatalogCharge.new
		actually.name = "testcharge"
		assert_not_equal actually, nil
		assert_equal actually.name, "testcharge"
	end
end