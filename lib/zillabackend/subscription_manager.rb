module ZillaBackend
	class SubscriptionManager
		def self.preview_cart(cart)

			sub_preview = ZillaBackend::Models::SubscribePreview.new

			if cart == nil || cart.cart_items.size <= 0
				sub_preview.invoice_amount = 0
				sub_preview.success = false
				sub_preview.error = "EMPTY_CART"
				return sub_preview
			end

			today = DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")

			#set up the account
			acc = Zuora::Objects::Account.new
			acc.auto_pay = 0;
			acc.currency = Config.default_currency
			acc.name = "test name"
			acc.payment_term = Config.default_payment_term
			acc.batch = Config.default_batch
			#set up the contact
			con = Zuora::Objects::Contact.new
			con.County = Config.default_country
			con.State = Config.default_state
			con.first_name = "test first"
			con.last_name  = "test last"
			#subscribe options

			#preview options

			#setup the susbcription

			sub_preview
		end
	end
end