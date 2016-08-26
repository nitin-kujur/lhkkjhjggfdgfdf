class Shop < ActiveRecord::Base
  include ShopifyApp::Shop
  include ShopifyApp::SessionStorage

	def self.calculate_min_shipping_rate(country, province, base_price, base_weight)
		price = base_price.to_f
		weight = base_weight.to_f
		@shipping_zones = ShopifyAPI::ShippingZone.find(:all) if @shipping_zones.blank?
		available_prices = []
		@shipping_zones.each do |shipping_zone|
			sp_country = shipping_zone.countries.select{|s| s.name == country}.first
			sp_province = sp_country.present? ? sp_country.provinces.select{|s| s.name == province} : nil
			if sp_province.present?
				shipping_zone.weight_based_shipping_rates.each do |rate_provider|
					if rate_provider.weight_low.to_f <= weight && rate_provider.weight_high.to_f >= weight
						available_prices << rate_provider.price.to_f
					end
				end
				shipping_zone.price_based_shipping_rates.each do |rate_provider|
					if rate_provider.min_order_subtotal.to_f <= price && (rate_provider.max_order_subtotal == nil || rate_provider.max_order_subtotal.to_f >= price)
						available_prices << rate_provider.price.to_f
					end
				end
			end
		end
		return (available_prices.blank? ? 0.0 : available_prices.min)
	end
end
