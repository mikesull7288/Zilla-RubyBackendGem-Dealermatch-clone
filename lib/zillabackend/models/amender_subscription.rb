module ZillaBackend
	class Models::AmenderSubscription
		attr_accessor :user_email, :sub_id, :version, :active_plans, :removed_plans, :end_of_term_date, :start_date

		def initialize
			self.active_plans = Array.new
			self.removed_plans = Array.new
		end
	end
end