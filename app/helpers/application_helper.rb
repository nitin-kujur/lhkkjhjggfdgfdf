module ApplicationHelper

	def get_shipping_options
		shipping_options = []
		ss = ShopifyAPI::ShippingZone.find(:all)
		ss.each do |s|
			shipping_options << 'Base On Weight' if s.weight_based_shipping_rates.present?
			shipping_options << 'Base On Price' if s.price_based_shipping_rates.present?
			s.carrier_shipping_rate_providers.each do |c|
				shipping_options += c.service_filter.attributes.select{|s,v| v=='+' && s !='*'}.keys
			end
		end
		shipping_options.uniq
	end
end
