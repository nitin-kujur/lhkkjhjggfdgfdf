class CustomWebhooksController < ApplicationController
  #include ShopifyApp::WebhookVerification

  def carts_update
  	puts params.inspect
  	head :ok
    respond_to do |format|
      format.html { }
      format.json { }
      format.js {}
    end
  end
end