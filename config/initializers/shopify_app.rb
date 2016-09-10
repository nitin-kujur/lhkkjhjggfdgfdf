ShopifyApp.configure do |config|
  config.api_key = ENV["shopify_api_key"]
  config.secret = ENV["shopify_secret"]
  config.scope = "write_orders, read_orders, read_products, read_customers, write_customers, write_shipping"
  config.embedded_app = true	
  config.webhooks = [
    {topic: 'carts/create', address: 'https://shopify-bulk-order.herokuapp.com/webhooks/carts_update', format: "json"}
  ]
end
SITE_URL = 'https://shopify-bulk-order.herokuapp.com'