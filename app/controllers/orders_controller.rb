class OrdersController < ApplicationController
  include ShopifyApp::AppProxyVerification

  before_action :set_session

  def index
    @orders = ShopifyAPI::Order.find(:all)
  end

  def place_bulk_order
    session[:bulk_order] = {} if session[:bulk_order].blank?
    if params[:action_type]=='list-location'
      @distributors = ShopifyAPI::Customer.find(:all)
      render :template => 'distributors/get_distributors.html.haml'
    elsif params[:action_type]=='list-product'
      @products = ShopifyAPI::Product.find(:all)
      render :template => 'home/index.html.haml'
    elsif params[:action_type]=='save-product-list'
      session[:bulk_order]['products'] = params[:products]
      session[:bulk_order]['distributors'] = params[:locations]
    elsif params[:action_type]=='save-location-list'
      session[:bulk_order]['products'] = params[:products]
      session[:bulk_order]['distributors'] = params[:distributors]
    elsif params[:action_type]=='session_clear'
      session[:bulk_order]= nil
    elsif params[:action_type]=='new-location'
      @distributor = Distributor.new
      @address = @distributor.addresses.build
      render :template => 'distributors/new.html.haml'
    elsif params[:action_type]=='create-location'
      create_location(params)
    elsif params[:action_type]=='edit-location'
      @distributor = sync_location(params[:id])
      @address = @distributor.addresses.first ? @distributor.addresses.first : @distributor.addresses.build
      render :template => 'distributors/edit.html.haml'
    elsif params[:action_type]=='update-location'
      @distributor = Distributor.find(params[:id])
      update_location(params)
    elsif params[:action_type]=='save_orders'
      session[:bulk_order]['products'] = params[:products]
      session[:bulk_order]['distributors'] = params[:locations]
      bulk_order()
    elsif params[:action_type]=='list_orders'
      @orders = ShopifyAPI::Order.find(:all)
      render :template => 'orders/index.html.haml'
    elsif params[:action_type]=='fetch_shipping'
      begin
        amount = Shop.calculate_min_shipping_rate(params[:shipping_type],params[:country],params[:country_code], params[:province],params[:province_code], params[:city], params[:zip], params[:price], params[:weight])
      rescue => ex
        amount = ex.message
      end
      respond_to do |format|
        format.json { render json: {'distributor_id' => params[:distributor_id], 'shipping_amount' =>  amount} }
      end
    end
    
  end

  def update_location(params)
    if @distributor.update(distributor_params)
      customer = ShopifyAPI::Customer.find(@distributor.shopify_id)
      customer.first_name = params[:distributor][:first_name]
      customer.last_name = params[:distributor][:last_name]
      customer.email =  params[:distributor][:email]
      customer.verified_email =params[:distributor][:verified_email]
      ad = params[:distributor][:addresses_attributes].first[1]
      if customer.addresses.present? 
        customer.addresses[0].address1 = ad[:address1]
        customer.addresses[0].city = ad[:city]
        customer.addresses[0].province = ad[:province]
        customer.addresses[0].phone= ad[:phone]
        customer.addresses[0].zip= ad[:zip]
        customer.addresses[0].last_name= ad[:last_name]
        customer.addresses[0].first_name= ad[:first_name]
        customer.addresses[0].country= ad[:country] || 'United States'
      else
        # CREATE CUSTOMER ADDRESS
      end
      customer.save        
      flash[:notice] = 'Location was successfully updated.'
      @distributors = ShopifyAPI::Customer.find(:all)
      render :template => 'distributors/get_distributors.html.haml'
    else
      flash[:notice] = 'Location could not be saved'
      render :template => 'distributors/edit.html.haml'
    end
  end

  def create_location(params)
    customer_hash= {"customer": 
                    {"first_name": params[:distributor][:first_name],
                    "last_name": params[:distributor][:last_name],
                    "email": params[:distributor][:email],
                    "verified_email": params[:distributor][:verified_email],
                      "addresses": [
                         {
                           "address1": params[:distributor][:addresses_attributes]['0'][:address1],
                           "city": params[:distributor][:addresses_attributes]['0'][:city],
                           "province": params[:distributor][:addresses_attributes]['0'][:province],
                           "phone": params[:distributor][:addresses_attributes]['0'][:phone],
                           "zip": params[:distributor][:addresses_attributes]['0'][:zip],
                           "last_name": params[:distributor][:addresses_attributes]['0'][:last_name],
                           "first_name": params[:distributor][:addresses_attributes]['0'][:first_name],
                           "country": params[:distributor][:addresses_attributes]['0'][:country] || 'United States'
                         }
                      ]
                    }
                  }
    
    @distributor = Distributor.new(distributor_params)
    @shop_customer = ShopifyAPI::Customer.create(customer_hash)
    if @shop_customer.save
      @distributor.shopify_id = @shop_customer.id
      @distributor.save
      @distributors = ShopifyAPI::Customer.find(:all)
      flash[:notice] = 'Location was successfully created.'
      render :template => 'distributors/get_distributors.html.haml'
    else
      flash[:notice] = 'Location could not be saved'
      render :template => 'distributors/new.html.haml'
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
      shipping_line = {code: params[:shipping_type],
                      price: values["shipping_amount"],
                      source: 'Bulk Order APP',
                      title: params[:shipping_type],
                      carrier_identifier: params[:shipping_type].split(' ').join('_')}
      financial_status = 'partially_paid'
      values[:product].each do |product_id, p_values|
        if p_values[:quantity].present? && p_values[:quantity].to_i > 0
          product = ShopifyAPI::Product.find(product_id)
          variant = product.variants.first
          line_items << {variant_id: variant.id, quantity: p_values[:quantity]}
        end
      end
      if line_items.present?
        order = ShopifyAPI::Order.new(shipping_lines: [shipping_line],line_items: line_items, customer: {id: customer.id}, billing_address: billing_address, shipping_address: shipping_address, financial_status: financial_status)
        if order.save
          @orders << order
        else
          @error_message[cust_id] = order.errors.full_messages.join(', ')
        end
      end
    end
    if @error_message.blank?
      @orders = ShopifyAPI::Order.find(:all)
      render :template => 'orders/index.html.haml'
    else
      @orders.each do |order|
        order.destroy
      end
      render :place_bulk_order
    end
  end

  def sync_location(customer_id)
    distributor = Distributor.find_by_shopify_id(customer_id)
    if distributor.blank? 
      customer = ShopifyAPI::Customer.find(customer_id)
      distributor = Distributor.new(email: customer.email, first_name: customer.first_name,
        last_name: customer.last_name, verified_email: customer.verified_email,shopify_id: customer.id)
      if distributor.save
        customer.addresses.each do |ad|
          address = distributor.addresses.build
          address.first_name = ad.first_name
          address.last_name = ad.last_name
          address.address1 = ad.address1
          address.city = ad.city
          address.province = ad.province
          address.phone = ad.phone
          address.zip = ad.zip
          address.country = ad.country
          address.save
        end
      end
    end
    distributor
  end
  private
    def distributor_params
      params.require(:distributor).permit(:first_name, :last_name, :email, :verified_email, addresses_attributes: [:id, :address1, :first_name, :last_name, :city, :phone, :zip, :country, :province])
    end

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
