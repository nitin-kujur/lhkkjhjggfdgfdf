class HomeController < ApplicationController
  before_action :authenticate_user!
  include ShopifyApp::AppProxyVerification
  
  def index
  	session[:bulk_order] = {} if session[:bulk_order].blank? || params[:session_clear].present?
    @products = ShopifyAPI::Product.find(:all)
  end
end
