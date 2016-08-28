class AppProxyController < ApplicationController
  include ShopifyApp::AppProxyVerification

  before_action :set_session

  def index
  end

  private
  
    def set_session
      session[:shopify_details] = {}
      session[:shopify_details][:shop] = params[:shop]
      session[:shopify_details][:path_prefix] = params[:path_prefix]
      session[:shopify_details][:signature] = params[:signature]
    end
end
