ShopifyApp.configure do |config|
  config.api_key = ENV["shopify_api_key"]
  config.secret = ENV["shopify_secret"]
  config.scope = "read_script_tags, write_script_tags, write_orders, read_orders, read_products, read_customers, write_customers, write_shipping"
  config.embedded_app = true	
end
SITE_URL = 'http://ec2-52-88-152-46.us-west-2.compute.amazonaws.com'