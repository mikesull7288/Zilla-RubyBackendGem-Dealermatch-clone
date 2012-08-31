require 'helper'

class CatalogTest < Test::Unit::TestCase
	include ZillaBackendTestHelper

	def test_refresh_catalog
		actually = ZillaBackend::Catalog.refresh_cache
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
		actually = ZillaBackend::Models::CatalogProduct.new
		assert_not_equal actually, nil
	end
end