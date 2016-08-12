class DistributorsController < ShopifyApp::AuthenticatedController
  # include ShopifyApp::AppProxyVerification

  def index
  	@distributors = ShopifyAPI::Customer.find(:all, :params => {:limit => 10})
  	# @products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})	
  end

  def create
  	customer_hash= {
					  "customer": {
					    "first_name": "Steve",
					    "last_name": "Lastnameson",
					    "email": "arpitvaishnav@gmail.com",
					    "verified_email": true,
					    "addresses": [
					      {
					        "address1": "123 Oak St",
					        "city": "Ottawa",
					        "province": "ON",
					        "phone": "555-1212",
					        "zip": "123 ABC",
					        "last_name": "Lastnameson",
					        "first_name": "Mother",
					        "country": "CA"
					      }
					  #   , {
							# "address1": "12 Oak St",
					  #       "city": "Ottawa",
					  #       "province": "ON",
					  #       "phone": "555-121",
					  #       "zip": "123 ABC",
					  #       "last_name": "Lastnameson",
					  #       "first_name": "Mother",
					  #       "country": "CA"
					  #   	}
						]
					  }
					}
  	@distributors = ShopifyAPI::Customer.create(customer_hash)
  end
end
