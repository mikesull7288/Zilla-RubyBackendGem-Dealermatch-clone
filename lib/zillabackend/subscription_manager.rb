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
			pandc = Array.new
			#make a product rate plan for each cart item
			cart.cart_items.each do |item|
				charge_list = Array.new
				prp = Zuora::Objects::ProductRatePlan.new
				prp.id = item.rate_plan_id
				#make a rate plan charge for each charge in the cart item charge
				if item.quantity != nil && item.quantity != 1
					charges = ZillaBackend::Catalog.get_rate_plan item.id
					charges.each do |charge|
						prpc = Zuora::Objects::RatePlanCharge.new
						prpc.id = charge.id
						prpc.quantity = charge.quantity
						charge_list << prpc
					end
				end
				pandc << {rate_plan: prp, charges: charge_list}
			end

			#preview options
			sub_request.preview_options = {:enable_preview_mode => true, :number_of_periods => 1}
			#susbcribe options
			sub_request.subscribe_options = {:generate_invoice => false, :process_payments => false}
			
			sub_request.account = acc
			sub_request.bill_to_contact = con
			sub_request.subscription = sub
			#sub_request.payment_method = nil
			sub_request.plans_and_charges = pandc

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