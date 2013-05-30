require 'test/unit'
require 'zillabackend'
require 'bundler/setup'

module ZillaBackendTestHelper

	def login
		ZillaBackend::Config.initialize(username: "smogger914@yahoo.com", pass: "Zuora002", sandbox: true, logger: true)
		Zuora.configure(username: "smogger914@yahoo.com", password: "Zuora002", sandbox: true, logger: true)
	end

	def create_test_subscribe
		today = DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")

		#setup the SubscribeRequest
		sub_request = Zuora::Objects::SubscribeRequest.new

		#set up the account
		acc = Zuora::Objects::Account.new
		acc.currency = "USD"
		acc.name = "ApiTestAccount"
		acc.payment_term = "Due Upon Receipt"
		acc.batch = "Batch1"
		acc.bill_cycle_day = 1
		#acc.status = "Draft"
		#set up the contact
		con = Zuora::Objects::Contact.new
		con.country = "USA"
		con.state = "CA"
		con.first_name = "test first"
		con.last_name  = "test last"
		#setup the payment method
		pay = Zuora::Objects::PaymentMethod.new
		pay.credit_card_address1  ="somewhere"
		pay.credit_card_city = "someplace"
	  pay.credit_card_country = "USA"
	  pay.credit_card_expiration_month = 1
	  pay.credit_card_expiration_year = 2020
	  pay.credit_card_holder_name = "Test Test"
	  pay.credit_card_number = "4111111111111111"
	  pay.credit_card_postal_code = "95050"
	  pay.credit_card_security_code = "123"
	  pay.credit_card_state = "CA"
	  pay.credit_card_type = "Visa"
	  pay.type = "CreditCard"

		#setup the susbcription
		sub = Zuora::Objects::Subscription.new
		sub.contract_effective_date = today
		sub.service_activation_date = today
		sub.contract_acceptance_date = today
		sub.term_start_date = today
		sub.term_type = "EVERGREEN"

		prod_rate_plans = Array.new
		rate_plan = Zuora::Objects::ProductRatePlan.new

		rate_plan.id = get_product_rate_plan_id
		prod_rate_plans << rate_plan

		#preview options
		sub_request.preview_options = {:enable_preview_mode => false, :number_of_periods => 1}
		#susbcribe options
		sub_request.subscribe_options = {:generate_invoice => true, :process_payments => false}
			
		sub_request.account = acc
		sub_request.bill_to_contact = con
		sub_request.payment_method = pay
		sub_request.subscription = sub
		
		sub_request.plans_and_charges = Array.new << {rate_plan: rate_plan, charges: nil }
		sub_request.create
	end

	def clear_test_stuff
		acc_res = Zuora::Objects::Account.where(name: 'ApiTestAccount')
		acc_res.each do |acc|
			acc.destroy
		end unless acc_res == []
	end

	def get_product_rate_plan_id
		cache = ZillaBackend::Catalog.read_from_cache
		rate_plan_id = cache[0]["products"][0]["rate_plans"][0]["id"]
	end
end