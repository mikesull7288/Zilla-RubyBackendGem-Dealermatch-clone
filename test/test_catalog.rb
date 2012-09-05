require 'helper'


class CatalogTest < Test::Unit::TestCase
	include ZillaBackendTestHelper

	def test_get_rate_plan
		actually = ZillaBackend::Catalog.get_rate_plan("4028e6963457a2a001345936b60d33fa")
		assert_equal actually, false
	end

	def test_load_from_cache
		actually = ZillaBackend::Catalog.read_from_cache
		assert_not_equal actually, nil
	end

	def test_refresh_catalog		
		actually = ZillaBackend::Catalog.refresh_cache
		assert_not_equal actually, nil
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