require 'uuidtools'
require 'digest/md5'

module ZillaBackend
	class PaymentManager

		PAGE_ID=Config.page_id
  	TENANT_ID=Config.tenant_id
  	API_SECURITY_KEY=Config.api_security_key
  	APP_URL = Config.app_url

  	def self.get_iframe_url
      token = UUIDTools::UUID.random_create.hexdigest # token should be unique, but don't have to be secure random
      timestamp = get_timestamp()

      signature = calc_signature(PAGE_ID, TENANT_ID, timestamp, token)

      query_string = "id=#{PAGE_ID}&tenantId=#{TENANT_ID}&timestamp=#{timestamp}&token=#{token}"
      @iframeurl = "#{APP_URL}/apps/PublicHostedPaymentMethodPage.do?method=requestPage&#{query_string}&signature=#{signature}"
  	end

  	private

	  def self.calc_signature(id, tenantId, timestamp, token)
	    query_string = "id=#{id}&tenantId=#{tenantId}&timestamp=#{timestamp}&token=#{token}"
	    query_string_and_key = "#{query_string}#{API_SECURITY_KEY}"

	    # query_string_and_key is always in ascii-8 bit / UTF-8 format, the same. no UTF-16 here.

	    query_hash = Digest::MD5.hexdigest(query_string_and_key)
	    Base64.encode64(query_hash).gsub("\n", '').gsub("+", "-").gsub("/", "_")
	  end

	  def self.get_timestamp
	    time = Time.now
	    pst_time = time.in_time_zone("Pacific Time (US & Canada)")
	    timestamp = (pst_time.to_f*1000).to_i # milliseconds since Epoch
	  end
	end
end