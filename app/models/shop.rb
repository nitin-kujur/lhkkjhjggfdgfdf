class Shop < ActiveRecord::Base
  include ShopifyApp::Shop
  include ShopifyApp::SessionStorage

  has_many :products

	def self.calculate_min_shipping_rate(shipping_type, country, country_code, province, province_code, city, zip_code, base_price, base_weight)
		price = base_price.to_f
		weight = base_weight.to_f
		available_prices = []
		available_shipping = false
		if shipping_type.present?
			@shipping_zones = ShopifyAPI::ShippingZone.find(:all) if @shipping_zones.blank?
			@shipping_zones.each do |shipping_zone|
				sp_country = shipping_zone.countries.select{|s| s.name == country}.first
				sp_province = sp_country.present? ? sp_country.provinces.select{|s| s.name == province} : nil
				if sp_province.present?
					available_shipping = true
					if shipping_type == 'Base On Weight'
						shipping_zone.weight_based_shipping_rates.each do |rate_provider|
							if rate_provider.weight_low.to_f <= weight && rate_provider.weight_high.to_f >= weight
								available_prices << rate_provider.price.to_f
							end
						end
					end
					if shipping_type == 'Base On Price'
						shipping_zone.price_based_shipping_rates.each do |rate_provider|
							if rate_provider.min_order_subtotal.to_f <= price && (rate_provider.max_order_subtotal == nil || rate_provider.max_order_subtotal.to_f >= price)
								available_prices << rate_provider.price.to_f
							end
						end
				  end
					if shipping_type.include?('UPS')
						shop = ShopifyAPI::Shop.current
						origin_details = {country: shop.country_code, province: shop.province_code, city: shop.city, zip: shop.zip}
						destination_details = {country: country_code, province: province_code, city: city, zip: zip_code}
						ups_rates = get_ups_shipping_rate(weight, origin_details, destination_details)
						available_option = ups_rates.select{|k| k.first==shipping_type}.first
						available_prices << ('%.2f' % (available_option.last.to_f/100)) if available_option.present?
				  end
				end
			end
		end
		if available_shipping.blank?
			return 'Shipping Not Available'
		else
		  return (available_prices.blank? ? 'Not found' : available_prices.min)
		end
	end

	def self.get_base_on_price_shipping_rate(price)
		packages = [ActiveShipping::Package.new(weight,[12, 8.75, 6], units: :imperial)]
		origin = ActiveShipping::Location.new(origin_details)
		destination = ActiveShipping::Location.new(destination_details)
		ups = ActiveShipping::UPS.new(login: ENV["ups_user_id"], password: ENV["ups_password"], key: ENV["ups_key"])
		response = ups.find_rates(origin, destination, packages)
	end

	def self.get_ups_shipping_rate(weight, origin_details, destination_details)
		packages = [ActiveShipping::Package.new(weight*16.1,[12, 8.75, 6], units: :imperial)]
		origin = ActiveShipping::Location.new(origin_details)
		destination = ActiveShipping::Location.new(destination_details)
		ups = ActiveShipping::UPS.new(login: ENV["ups_user_id"], password: ENV["ups_password"], key: ENV["ups_key"])
		response = ups.find_rates(origin, destination, packages)
		response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}
	end
end
