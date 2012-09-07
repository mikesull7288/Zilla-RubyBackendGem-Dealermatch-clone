require 'helper'

class ConfigTest < Test::Unit::TestCase
	include ZillaBackendTestHelper
	def test_set_config
		config = ZillaBackend::Config.new(username: "test", pass: "test")
		assert_equal config.username, "test"
		assert_equal config.pass, "test" 
	end
end