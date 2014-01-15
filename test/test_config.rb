require 'helper'

class ConfigTest < Test::Unit::TestCase
	include ZillaBackendTestHelper
	def test_set_config
		ZillaBackend::Config.initialize(username: "test", pass: "test", sandbox: true, logger: true)
		assert_equal ZillaBackend::Config.username, "test"
		assert_equal ZillaBackend::Config.pass, "test"
		assert_equal ZillaBackend::Config.sandbox, true
		assert_equal ZillaBackend::Config.logger, true
	end
end