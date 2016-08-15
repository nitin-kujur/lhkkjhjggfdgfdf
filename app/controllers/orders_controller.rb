class OrdersController < ApplicationController
   include ShopifyApp::AppProxyVerification

  def index
  	@products = ShopifyAPI::Product.find(:all)
    render layout: false, content_type: 'application/liquid'
  end

end
