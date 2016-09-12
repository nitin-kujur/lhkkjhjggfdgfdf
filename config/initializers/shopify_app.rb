ShopifyApp.configure do |config|
  config.api_key = ENV["shopify_api_key"]
  config.secret = ENV["shopify_secret"]
  config.scope = "read_line_items, write_line_items, read_script_tags, write_script_tags, write_orders, read_orders, read_products, read_customers, write_customers, write_shipping"
  config.embedded_app = true	
  config.webhooks = [
    {topic: 'carts/create', address: "https://shopify-bulk-order.herokuapp.com/carts_update", format: "json"},
    {topic: 'carts/update', address: "https://shopify-bulk-order.herokuapp.com/carts_update", format: "json"}
  ]
  config.scripttags = [
    {event:'onload', src: "https://shopify-bulk-order.herokuapp.com/update_quantity"}
  ]
end
SITE_URL = 'https://shopify-bulk-order.herokuapp.com'