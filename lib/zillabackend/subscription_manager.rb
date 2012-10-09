module ZillaBackend
	class SubscriptionManager
		Zuora.configure(username: Config.username, password: Config.pass, sandbox: Config.sandbox, logger: Config.logger)
	
		def self.preview_cart(cart)
			sub_preview = ZillaBackend::Models::SubscribePreview.new

			if cart == nil || cart.cart_items.size <= 0
				sub_preview.invoice_amount = 0
				sub_preview.success = false
				sub_preview.error = "EMPTY_CART"
				return sub_preview
			end

			today = DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")

			#setup the SubscribeRequest
			sub_request = Zuora::Objects::SubscribeRequest.new

			#set up the account
			acc = Zuora::Objects::Account.new

			acc.currency = Config.default_currency
			acc.name = "test name"
			acc.payment_term = Config.default_payment_term
			acc.batch = Config.default_batch
			acc.bill_cycle_day = 1
			acc.status = "Draft"
			#set up the contact
			con = Zuora::Objects::Contact.new
			con.country = Config.default_country
			con.state = Config.default_state
			con.first_name = "test first"
			con.last_name  = "test last"
			#setup the susbcription
			sub = Zuora::Objects::Subscription.new
			sub.contract_effective_date = today
			sub.service_activation_date = today
			sub.contract_acceptance_date = today
			sub.term_start_date = today
			sub.term_type = "EVERGREEN"
			prod_rate_plans = Array.new

			#make a product rate plan for each cart item
			cart.cart_items.each do |item|
				prp = Zuora::Objects::ProductRatePlan.new
				prp.id = item.rate_plan_id
				prod_rate_plans << prp
			end

			#TODO
			#set the quantity on the charges if necessary

			#preview options
			sub_request.preview_options = {:enable_preview_mode => true, :number_of_periods => 1}
			#susbcribe options
			sub_request.subscribe_options = {:generate_invoice => false, :process_payments => false}
			
			sub_request.account = acc
			sub_request.bill_to_contact = con
			sub_request.subscription = sub
			#sub_request.payment_method = nil
			sub_request.product_rate_plans = prod_rate_plans

			sub_res = sub_request.create
			if sub_res[:success] == true
				sub_preview.invoice_amount = sub_res[:invoice_data][:invoice][:amount]
				sub_preview.success = true
			else
				sub_preview.success = false
				sub_preview.error = sub_res[:errors][:message]
			end

			sub_preview
		end
	end
end