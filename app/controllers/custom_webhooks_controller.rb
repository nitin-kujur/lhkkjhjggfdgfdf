class CustomWebhooksController < ApplicationController
	before_action :set_session
  include ShopifyApp::WebhookVerification

  def carts_update
  	puts params.inspect
    respond_to do |format|
      format.html { }
      format.json { }
      format.js {}
    end
  end
  def set_session
    params[:shop] = 'pepsi-test.myshopify.com' if params[:shop].blank? || Rails.env.development?
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