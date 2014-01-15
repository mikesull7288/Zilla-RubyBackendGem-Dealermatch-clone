require 'helper'

class AccountManagerTest < Test::Unit::TestCase
	include ZillaBackendTestHelper
	
	def test_can_we_check_email_availability
		login
		actually = ZillaBackend::AccountManager.check_email_availability("test@test.com")
		assert_equal false, actually
	end

	def test_can_we_get_contact_detail
		login
		actually = ZillaBackend::AccountManager.get_contact_detail("test@test.com")
		assert_not_equal actually, nil
	end

	def test_can_we_make_a_summary_contact
		login
		actually = ZillaBackend::Models::SummaryContact.new
		assert_not_equal actually, nil
	end
end