require 'helper'

class PaymentManagerTest < Test::Unit::TestCase
	include ZillaBackendTestHelper
	
	def test_can_generate_iframe_src
		actually = ZillaBackend::PaymentManager.get_iframe_url
		assert_not_equal actually, nil
	end

end