class AppProxyController < ApplicationController
  include ShopifyApp::AppProxyVerification

  before_action :set_session

  def index
  end

  private
  
    def set_session
      if session[:shopify].blank?
        if params[:shop].present?
          shop = Shop.find_by_shopify_domain(params[:shop])
          if shop.present?
            sess = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
            session[:shopify] = ShopifyApp::SessionRepository.store(sess)
            ShopifyAPI::Base.activate_session(sess)
            session[:shopify_domain] = shop.shopify_domain
          end
        end
      end
    end
end
