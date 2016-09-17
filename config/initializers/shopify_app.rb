ShopifyApp.configure do |config|
  config.api_key = ENV["shopify_api_key"]
  config.secret = ENV["shopify_secret"]
  config.scope = "read_script_tags, write_script_tags, write_orders, read_orders, read_products, read_customers, write_customers, write_shipping"
  config.embedded_app = true	
  config.webhooks = [
    {topic: 'carts/create', address: "https://http://ec2-52-88-152-46.us-west-2.compute.amazonaws.com/carts_update", format: "json"},
    {topic: 'carts/update', address: "https://http://ec2-52-88-152-46.us-west-2.compute.amazonaws.com/carts_update", format: "json"}
  ]
  config.scripttags = [
    {event:'onload', src: "http://ec2-52-88-152-46.us-west-2.compute.amazonaws.com/update_quantity"}
  ]
end
SITE_URL = 'http://ec2-52-88-152-46.us-west-2.compute.amazonaws.com'