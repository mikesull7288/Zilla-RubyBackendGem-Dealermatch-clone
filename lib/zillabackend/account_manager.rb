module ZillaBackend
  class AccountManager
		Zuora.configure(username: Config.username, password: Config.pass, sandbox: Config.sandbox, logger: Config.logger)
	
		def self.check_email_availability(target_email)
			qRes = Zuora::Objects::Contact.where(work_email: target_email)
			qRes.count == 0 ? true : false
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
  end
end	