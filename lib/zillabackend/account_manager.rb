module ZillaBackend
  class AccountManager
		Zuora.configure(username: Config.username, password: Config.pass, sandbox: Config.sandbox, logger: Config.logger)
	
		def self.check_email_availability(target_email)
			qRes = Zuora::Objects::Contact.where(work_email: target_email)
			qRes.count == 0 ? false : true
		end

		def self.get_contact_detail(account_name)
			con_detail = ZillaBackend::Models::SummaryContact.new
			account_id = ''
			q_res = Zuora::Objects::Account.where(name: account_name)
			q_res.each do |acc|
				account_id = acc.id
			end
			
			if account_id == ''
				con_detail.success = false
				con_detail.error = 'USER_DOESNT_EXIST'
				return con_detail
			end

			con_res = Zuora::Objects::Contact.where(account_id: account_id)
			if con_res.count == 0
				con_detail.success = false
				con_detail.error = 'CONTACT_DOESNT_EXIST'
				return con_detail
			end

			con_res.each do |con|
				con_detail.first_name = con.first_name
				con_detail.last_name = con.last_name
				con_detail.country = con.country
				con_detail.state = con.state ||= ''
				con_detail.address1 = con.address1 ||= ''
				con_detail.address2 = con.address2 ||= ''
				con_detail.city = con.city ||= ''
				con_detail.postal_code = con.postal_code ||= ''
				con_detail.success = true
			end
			con_detail
		end

		def self.get_account_detail(account_name)
			account_detail = ZillaBackend::Models::SummaryAccount.new

			account_id = ''
			q_res = Zuora::Objects::Account.where(name: account_name)
			q_res.each do |acc|
				account_id = acc.id
			end

			if account_id == ''
				account_detail.success = false
				account_detail.error = 'USER_DOESNT_EXIST'
				return account_detail
			end

			q_res.each do |acc|
				account_detail.name = acc.name
				account_detail.balance = acc.balance
				account_detail.last_Invoice_Date = acc.lastInvoiceDate == nil ? acc.lastInvoiceDate : nil

				payment_res = Zuora::Objects::Payment.where(account_id: account_id)
				if payment_res.count == 0
					account_detail.lastInvoiceDate = nil
					account_detail.lastInvoiceAmount = nil
				else
					account_detail.lastInvoiceDate = 0
					account_detail.lastInvoiceAmount = 0
				end

				
			end

			account_detail.success = true
			return account_detail

		end

		private
			def self.cmp_payments(a, b)
				if a.createdDate.eql? b.createdDate
					return 0
				else
					return a.createdDate > b.createdDate ? -1 : 1
				end	
			end

			def self.cmp_invoices(a, b)
				if a.createdDate == b.createdDate
					return 0
				else
					return a.createdDate > b.createdDate ? -1 : 1
				end
			end
  end
end	