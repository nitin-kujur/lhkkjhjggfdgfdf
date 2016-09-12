class CustomWebhooksController < ApplicationController
  include ShopifyApp::WebhookVerification

  def carts_update
  	puts params.inspect
  	params[:line_items].each do |s|
  		line_item = ShopifyAPI::LineItem.find(s['id'])
  		line_item.price = 20.00
  		line_item.save
  	end
    respond_to do |format|
      format.html { }
      format.json { }
      format.js {}
    end
  end
end