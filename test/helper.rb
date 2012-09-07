require 'test/unit'
require 'zillabackend'
require 'bundler/setup'

module ZillaBackendTestHelper
	ZillaBackend::Config.initialize(username: "smogger914@yahoo.com", pass: "Fo!d3168", sandbox: true, logger: true)
end