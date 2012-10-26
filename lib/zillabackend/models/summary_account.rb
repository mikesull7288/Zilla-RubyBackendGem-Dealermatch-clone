module ZillaBackend
	class Models::SummaryAccount
		attr_accessor :success, :error, :name, :balance, :last_payment_amount, :last_payment_date, :last_invoice_date, :contact_summary, :payment_method_summaries
	end
end