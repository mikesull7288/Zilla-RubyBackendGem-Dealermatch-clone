module ZillaBackend
	class Amender

		Zuora.configure(username: Config.username, password: Config.pass, sandbox: Config.sandbox, logger: Config.logger)

		def self.add_rate_plan(account_name, prp_id, qty, preview)
			amend_request = Zuora::Objects::AmendRequest.new
			sub = ZillaBackend::SubscriptionManager.get_current_subscription account_name

			amendment = Zuora::Objects::Amendment.new
			today = DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")
			amendment.effective_date = today
			amendment.contract_effective_date = today
			amendment.service_activation_date = today
			amendment.customer_acceptance_date = today
			amendment.name = 'Add Rate Plan'
			amendment.status = 'Completed'
			amendment.type = 'NewProduct'
			amendment.subscription_id = sub.sub_id

			product_rate_plan = Zuora::Objects::RatePlan.new
			product_rate_plan.product_rate_plan_id = prp_id

			rp = ZillaBackend::Catalog.get_rate_plan(prp_id)
			rpcs = Array.new
			rp["charges"].each do |charge|
				if ( charge["charge_model"] = 'Tiered Pricing' || charge["charge_model"] == 'Per Unit Pricing' || charge["charge_model"] == 'Volume Pricing') && charge["charge_type"] != 'Usage' 
					rpc = Zuora::Objects::RatePlanCharge.new
					rpc.quantity = qty
					rpc.product_rate_plan_charge_id = charge["id"]
					rpcs << rpc
				end
			end

			amend_request.amendment = amendment
			amend_request.preview_options = { enable_preview_mode: preview, number_of_periods: 1 }
			amend_request.amend_options = { generate_invoice: true, process_payments: true }
			amend_request.plans_and_charges = Array.new << { rate_plan: product_rate_plan, charges: rpcs }
			amend_request.create
		end

		def self.remove_rate_plan(account_name, rp_id, preview)
			amend_request = Zuora::Objects::AmendRequest.new
			sub = ZillaBackend::SubscriptionManager.get_current_subscription account_name

			amendment = Zuora::Objects::Amendment.new

			amendment.effective_date = sub.end_of_term_date
			amendment.contract_effective_date = sub.end_of_term_date
			amendment.service_activation_date = sub.end_of_term_date
			amendment.customer_acceptance_date = sub.end_of_term_date
			amendment.name = 'Remove Rate Plan'
			amendment.status = 'Completed'
			amendment.type = 'RemoveProduct'
			amendment.subscription_id = sub.sub_id

			product_rate_plan = Zuora::Objects::RatePlan.new
			product_rate_plan.amendment_subscription_rate_plan_id = rp_id

			amend_request.amendment = amendment
			amend_request.preview_options = { enable_preview_mode: preview, number_of_periods: 1 }
			amend_request.amend_options = { generate_invoice: !preview ? true : false, process_payments: !preview ? true : false }

			amend_request.create
		end

	end
end