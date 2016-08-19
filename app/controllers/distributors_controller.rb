class DistributorsController <  ShopifyApp::AuthenticatedController
  before_action :set_distributor, only: [:show, :edit, :update, :destroy]


  def get_prd_for_distri
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})
  end

  def set_prd_for_distri
    session[:bulk_order]['distributor'][params[:distributor_id]] = params[:order][0]["distributor"].values
    redirect_to place_bulk_order_path
  end

  def get_distributors
    @distributors = ShopifyAPI::Customer.find(:all)
  end

  def set_distributors_for_bulk
    if params[:session_clear]
    #[{"distributor"=>{"4337082118"=>["1", "1", "1"]}}]
      session[:bulk_order]= nil
    else
      session[:bulk_order]= {}
      params[:order].each do |o|
        session[:bulk_order][:distributor] = {}
        o.values[0].each do |value|
          session[:bulk_order][:distributor]["#{value}"] =  []    
        end
      end
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
      unless Distributor.exists?(email: customer.email)
        distributor = Distributor.new(email: customer.email, first_name: customer.first_name,
          last_name: customer.last_name, verified_email: customer.verified_email)
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
        # address.first_name = c
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
    #@distributors = Distributor.all
    @distributors = ShopifyAPI::Customer.find(:all)
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
					                 "country": params[:distributor][:addresses_attributes]['0'][:country]
					               }
  	 					        ]
     			          }
					        }
  	
    @distributor = Distributor.new(distributor_params)

    respond_to do |format|
      if @distributor.save
      	ShopifyAPI::Customer.create(customer_hash)
        format.html { redirect_to @distributor, notice: 'Distributor was successfully created.' }
        format.json { render :show, status: :created, location: @distributor }
      else
        format.html { render :new }
        format.json { render json: @distributor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /distributors/1
  # PATCH/PUT /distributors/1.json
  def update
    respond_to do |format|
      if @distributor.update(distributor_params)
        format.html { redirect_to @distributor, notice: 'Distributor was successfully updated.' }
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
      format.html { redirect_to distributors_url, notice: 'Distributor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_distributor
      @distributor = Distributor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def distributor_params
      params.require(:distributor).permit(:first_name, :last_name, :email, :verified_email, addresses_attributes: [:address1])
    end
end
