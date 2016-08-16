ShopifyApp.configure do |config|
  config.api_key = ENV["shopify_api_key"]
  config.secret = ENV["shopify_secret"]
  config.scope = "read_orders, read_products, read_customers, write_customers"
  config.embedded_app = true
end
