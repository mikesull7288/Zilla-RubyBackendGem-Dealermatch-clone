module ZillaBackend
	class SubscriptionManager

		Zuora.configure(username: Config.username, password: Config.pass, sandbox: Config.sandbox, logger: Config.logger)
	
		def self.get_current_subscription(account_name)
			today = DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")
			active_sub = ZillaBackend::Models::AmenderSubscription.new

			acc_query_res = Zuora::Objects::Account.where(name: account_name)
			if acc_query_res[0] == nil 
				return 'ACCOUNT_DOES_NOT_EXIST'
			end
			
			account_id = acc_query_res[0].id ||= nil
			sub_query_res = Zuora::Objects::Subscription.where(account_id: account_id, status: 'Active')

			if sub_query_res[0] == nil 
				return 'SUBSCRIPTION_DOES_NOT_EXIST'
			end

			active_sub.user_email = account_name
			active_sub.end_of_term_date = today

			active_sub.sub_id = sub_query_res[0].id
			active_sub.version = sub_query_res[0].version
			active_sub.start_date = sub_query_res[0].term_start_date
			#get active rate plans
			rate_plans = Zuora::Objects::RatePlan.where(subscription_id: active_sub.sub_id)
			new_plans = Array.new
			rate_plans.each do |rp|
				new_plan = ZillaBackend::Models::AmenderPlan.new
				new_plan.id = rp.id
				new_plan.name = rp.name
				#get product rate plan description
				product_rate_plans = Zuora::Objects::ProductRatePlan.where(id: rp.product_rate_plan_id)
				new_plan.description = product_rate_plans[0].description ||= ''
				#get product name
				products = Zuora::Objects::Product.where(id: product_rate_plans[0].product_id)
				new_plan.product_name = products[0].name				
				#get all charges
				rpcs = Zuora::Objects::RatePlanCharge.where(rate_plan_id: rp.id)
				rpcs.each do |rpc|
					new_charge = ZillaBackend::Models::AmenderCharge.new
					new_charge.id = rpc.id
					new_charge.name = rpc.name
					new_charge.charge_model = rpc.charge_model
					new_charge.product_rate_plan_charge_id = rpc.product_rate_plan_charge_id
					
					if rpc.charge_model != 'Flat Fee Pricing' && rpc.charge_type != 'Usage'
						new_plan.uom = rpc.uom
						new_plan.quantity = rpc.quantity
						new_charge.uom = rpc.uom
						new_charge.quantity = rpc.uom
					end
					
					if rpc.charged_through_date > active_sub.end_of_term_date
						active_sub.end_of_term_date = rpc.charged_through_date
					end unless rpc.charged_through_date == nil

					new_plan.amender_charges << new_charge
				end
				active_sub.active_plans << new_plan
			end
			#get removed rate plans
			rmvd_rps = Zuora::Objects::RatePlan.where(subscription_id: active_sub.sub_id, amendment_type: 'RemoveProduct')
			rmvd_rps.each do |rp|
				new_plan = ZillaBackend::Models::AmenderPlan.new
				new_plan.id = rp.id
				new_plan.name = rp.name
				#get product rate plan description
				product_rate_plans = Zuora::Objects::ProductRatePlan.where(id: rp.product_rate_plan_id)
				new_plan.description = product_rate_plans[0].description ||= ''
				#get product name
				products = Zuora::Objects::Product.where(id: product_rate_plans[0].product_id)
				new_plan.name = products[0].name

				new_plan.amendment_id = rp.amendment_id
				new_plan.amendment_type = rp.amendment_type

				#query amendment for this rate plan to get effective removal date
				amnd_res = Zuora::Objects::Amendment.where(id: new_plan.amendment_id)
				new_plan.effective_date = amnd_res[0].contract_effective_date

				#get all charges
				rpcs = Zuora::Objects::RatePlanCharge.where(rate_plan_id: rp.id)
				rpcs.each do |rpc|
					new_charge = ZillaBackend::Models::AmenderCharge.new
					new_charge.id = rpc.id
					new_charge.name = rpc.name
					new_charge.charge_model = rpc.charge_model
					new_charge.product_rate_plan_charge_id = rpc.product_rate_plan_charge_id
					
					if rpc.charge_model != 'Flat Fee Pricing' && rpc.charge_type != 'Usage'
						new_plan.uom = rpc.uom
						new_plan.quantity = rpc.quantity
						new_charge.uom = rpc.uom
						new_charge.quantity = rpc.uom
					end
					
					if rpc.charged_through_date > active_sub.end_of_term_date
						active_sub.end_of_term_date = rpc.charged_through_date
					end unless rpc.charged_through_date == nil

					new_plan.amender_charges << new_charge
				end
				active_sub.removed_plans << new_plan
			end

			active_sub
		end


		def self.subscribe_with_current_cart(user_email, pm_id, cart)

			if(cart == nil || cart.cart_items == nil)
				return 'CART_NOT_INITIALIZED'
			end

			if(user_email == nil)
				return 'USER_EMAIL_NOT_PROVIDED'
			end

			if(!ZillaBackend::AccountManager.check_email_availability(user_email))
				return 'DUPLICATE_EMAIL'
			end

			#Get Contact information from newly created payment method
			pm_result = Zuora::Objects::PaymentMethod.find(pm_id)

			if( pm_result == nil)
				return 'INVALID_PMID'
			end

			
			holder_name = pm_result.credit_card_holder_name ||= ''

			#Derive first and last name from CardHolderName
			split_str = holder_name.split(' ')
			first_name = split_str[0] ||= ''
			last_name = split_str[1] ||= ''

			address1 = pm_result.credit_card_address1 ||= ''
			address2 = pm_result.credit_card_address2 ||= ''
			city = pm_result.credit_card_city ||= ''
			country = pm_result.credit_card_country ||= ''
			postal_code = pm_result.credit_card_postal_code ||= ''
			state = pm_result.credit_card_state ||= ''
			phone = pm_result.phone ||= ''

			today = DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")
			#setup the account
			acc = Zuora::Objects::Account.new
			acc.currency = Config.default_currency
			acc.name = user_email
			acc.payment_term = Config.default_payment_term
			acc.batch = Config.default_batch
			acc.bill_cycle_day = 0
			acc.status = "Active"
			acc.bcd_setting_option = 'AutoSet'
			#set the payment method id
			pay = Zuora::Objects::PaymentMethod.new
			pay.id = pm_id
			#set up the contact
			con = Zuora::Objects::Contact.new
			con.country = country
			con.state = state
			con.first_name = first_name
			con.last_name  = last_name
			con.address1 = address1
			con.address2 = address2
			con.city = city
			con.country = country
			con.postal_code = postal_code
			con.state = state
			con.work_email = user_email
			con.work_phone = phone

			#Set up subscription
			subscription = Zuora::Objects::Subscription.new
			subscription.contract_effective_date = today
			subscription.service_activation_date = today
			subscription.contract_acceptance_date = today
			subscription.term_start_date = today
			subscription.term_type = "EVERGREEN"
			subscription.status = "Active"

			pandc = Array.new
			#make a product rate plan for each cart item
			cart.cart_items.each do |item|
				charge_list = Array.new
				prp = Zuora::Objects::ProductRatePlan.new
				prp.id = item.rate_plan_id
				#make a rate plan charge for each charge in the cart item charge
				if item.quantity != nil && item.quantity != 1
					rate_plan = ZillaBackend::Catalog.get_rate_plan item.rate_plan_id
					rate_plan["charges"].each do |charge|
						prpc = Zuora::Objects::RatePlanCharge.new
						prpc.product_rate_plan_charge_id = charge["id"]
						if prpc.charge_model != 'Usage'
							prpc.quantity = item.quantity
						end
						charge_list << prpc
					end
				end
				pandc << {rate_plan: prp, charges: charge_list}
			end
			#setup the SubscribeRequest
			sub_request = Zuora::Objects::SubscribeRequest.new
			#preview options
			sub_request.preview_options = {:enable_preview_mode => false, :number_of_periods => 1}
			#susbcribe options
			sub_request.subscribe_options = {:generate_invoice => true, :process_payments => true}
			
			sub_request.account = acc
			sub_request.bill_to_contact = con
			sub_request.subscription = subscription
			sub_request.payment_method = pay
			sub_request.plans_and_charges = pandc
			
			sub_res = sub_request.create
			
		end

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
					rate_plan = ZillaBackend::Catalog.get_rate_plan item.rate_plan_id
					rate_plan["charges"].each do |charge|
						prpc = Zuora::Objects::RatePlanCharge.new
						prpc.product_rate_plan_charge_id = charge["id"]
						prpc.quantity = item.quantity
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