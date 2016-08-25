ShopifyApp.configure do |config|
  config.api_key = ENV["shopify_api_key"]
  config.secret = ENV["shopify_secret"]
  config.scope = "write_orders, read_orders, read_products, read_customers, write_customers, read_addresses, write_addresses"
  config.embedded_app = false
end
