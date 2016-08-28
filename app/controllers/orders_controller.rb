class OrdersController < ApplicationController
  include ShopifyApp::AppProxyVerification

  before_action :set_session

  def index
    @orders = ShopifyAPI::Order.find(:all)
  end

  def place_bulk_order
    session[:bulk_order] = {} if session[:bulk_order].blank? || params[:session_clear].present?
    if params[:action_type]=='list-location'
       @distributors = Distributor.where.not(shopify_id: nil).order('created_at DESC')
      render :template => 'distibutors/get_distributors'
    end
  end

	def bulk_order
    @error_message = {}
    @orders = []
    params[:order][:distributors].each do |cust_id, values|
      customer = ShopifyAPI::Customer.find(cust_id)
      line_items = []
      default_address = customer.default_address
      address = customer.addresses.first
      billing_address = {first_name: default_address.first_name, 
                        last_name: default_address.last_name, 
                        address1: default_address.address1,
                        phone: default_address.phone,
                        city: default_address.city,
                        province: default_address.province,
                        country: default_address.country,
                        zip: default_address.zip}
      shipping_address = {first_name: address.first_name, 
                        last_name: address.last_name, 
                        address1: address.address1,
                        phone: address.phone,
                        city: address.city,
                        province: address.province,
                        country: address.country,
                        zip: address.zip}
      financial_status = 'partially_paid'
      values[:product].each do |product_id, p_values|
        if p_values[:quantity].present? && p_values[:quantity].to_i > 0
          product = ShopifyAPI::Product.find(product_id)
          variant = product.variants.first
          line_items << {variant_id: variant.id, quantity: p_values[:quantity]}
        end
      end
      if line_items.present?
        order = ShopifyAPI::Order.new(line_items: line_items, customer: {id: customer.id}, billing_address: billing_address, shipping_address: shipping_address, financial_status: financial_status)
        if order.save
          @orders << order
        else
          @error_message[cust_id] = order.errors.full_messages.join(', ')
        end
      end
    end
    if @error_message.blank?
      redirect_to orders_path, notice: 'Bulk Orders have been successfully created.'
    else
      @orders.each do |order|
        order.destroy
      end
      render :place_bulk_order
    end
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
