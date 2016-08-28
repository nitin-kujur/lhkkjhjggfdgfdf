class DistributorsController < ApplicationController
 
  before_action :set_distributor, only: [:show, :edit, :update, :destroy]
  before_action :set_session

  def get_prd_for_distri
    @products = ShopifyAPI::Product.find(:all)
  end

  def set_prd_for_distri
    session[:bulk_order]['products'] = params[:products]
    redirect_to place_bulk_order_path
  end

  def get_distributors
    @distributors = Distributor.where.not(shopify_id: nil).order('created_at DESC')
  end

  def set_distributors_for_bulk
    if params[:session_clear]
      session[:bulk_order]= nil 
    else
      session[:bulk_order]= {} if(session[:bulk_order] == nil)
      session[:bulk_order]['distributors'] = params[:distributors]
    end
    redirect_to place_bulk_order_path
  end
  
  # GET /distributors
  # GET /distributors.json
  def sync_distributors
    #get customers and sync on the system    
    message= "Sync successfully"
    customers_from_shop = ShopifyAPI::Customer.find(:all)
    customers_from_shop.each do |customer|
      distributor = Distributor.find_by_email(customer.email)
      if distributor.blank? 
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
      else
        distributor.update_attributes(shopify_id: customer.id)
        customer.addresses.each do |ad|
          address = distributor.addresses.first ||  distributor.addresses.build
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
    respond_to do |format|
      format.html { redirect_to distributors_url, notice: message}
      format.json { head :no_content }
    end

    #@distributors = ShopifyAPI::Customer.find(:all)
  end


  # GET /distributors
  # GET /distributors.json
  def index
    @distributors = Distributor.where.not(shopify_id: nil).order('created_at DESC')
    # @distributors = ShopifyAPI::Customer.find(:all)
    render :get_distributors
  end

  # GET /distributors/1
  # GET /distributors/1.json
  def show
  end

  # GET /distributors/new
  def new
    @distributor = Distributor.new
    @address = @distributor.addresses.build
  end

  # GET /distributors/1/edit
  def edit
    @address = @distributor.addresses.first ? @distributor.addresses.first : @distributor.addresses.build
  end

  # POST /distributors
  # POST /distributors.json
  def create
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
    respond_to do |format|
      @shop_customer = ShopifyAPI::Customer.create(customer_hash)
      if @shop_customer.save
        @distributor.shopify_id = @shop_customer.id
        @distributor.save
        format.html { redirect_to @distributor, notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @distributor }
      else
        format.html { render :new }
        format.json { render json: @shop_customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /distributors/1
  # PATCH/PUT /distributors/1.json
  def update
    respond_to do |format|
      if @distributor.update!(distributor_params)
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
        format.html { redirect_to @distributor, notice: 'Location was successfully updated.' }
        format.json { render :show, status: :ok, location: @distributor }
      else
        format.html { render :edit }
        format.json { render json: @distributor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /distributors/1
  # DELETE /distributors/1.json
  def destroy
    @distributor.destroy
    respond_to do |format|
      format.html { redirect_to distributors_url, notice: 'Location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_shipping_amount
  begin
    amount = Shop.calculate_min_shipping_rate(params[:shipping_type],params[:country],params[:country_code], params[:province],params[:province_code], params[:city], params[:zip], params[:price], params[:weight])
  rescue => ex
    amount = ex.message
  end
    
    respond_to do |format|
      format.json { render json: {'distributor_id' => params[:distributor_id], 'shipping_amount' =>  amount} }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_distributor
      @distributor = Distributor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
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
