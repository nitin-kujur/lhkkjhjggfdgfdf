class AppProxyController < ApplicationController
   include ShopifyApp::AppProxyVerification

  def index
    session[:bulk_order] = {} if session[:bulk_order].blank? || params[:session_clear].present?
  	# @distibutors = ShopifyAPI::Customer.where(id: session[:bulk_order]['distributor'].keys)
  end

end
