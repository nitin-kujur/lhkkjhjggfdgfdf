class CustomWebhooksController < ApplicationController
  # include ShopifyApp::WebhookVerification
  layout false
  def carts_update
  	puts params.inspect
    respond_to do |format|
      format.html { }
      format.json { }
      format.js {}
    end
  end
end