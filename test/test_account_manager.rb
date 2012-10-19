require 'helper'

class AccountManagerTest < Test::Unit::TestCase
	include ZillaBackendTestHelper
	
	def test_can_we_check_email_availability
		actually = ZillaBackend::AccountManager.check_email_availability("test@test.com")
		assert_equal actually, true
	end

	def test_can_we_get_contact_detail
		actually = ZillaBackend::AccountManager.get_contact_detail("test name")
		assert_not_equal actually, nil
	end

	def test_can_we_make_a_summary_contact
		actually = ZillaBackend::Models::SummaryContact.new
		assert_not_equal actually, nil
	end

	def test_can_we_make_a_summary_account
		actually = ZillaBackend::Models::SummaryAccount.new
		assert_not_equal actually,nil
	end
end