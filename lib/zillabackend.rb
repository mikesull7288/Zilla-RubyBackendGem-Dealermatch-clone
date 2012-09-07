require 'bundler/setup'
require 'zuora'

module ZillaBackend

	autoload :Models, 		 	'zillabackend/models'
	autoload :Catalog, 		 	'zillabackend/catalog'
	autoload :Cart, 		 	'zillabackend/cart'
	autoload :Config, 		 	'zillabackend/config'

end