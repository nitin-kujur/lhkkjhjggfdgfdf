class OrdersController <  ShopifyApp::AuthenticatedController
   #include ShopifyApp::AppProxyVerification

  def index
    # render layout: false, content_type: 'application/liquid'
  end

  def place_bulk_order
  	# @distibutors = ShopifyAPI::Customer.where(id: session[:bulk_order]['distributor'].keys)
  end

	def bulk_order
    # byebug
    render text: params and return false
  end

end
