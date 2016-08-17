class DistributorsController <  ShopifyApp::AuthenticatedController
  before_action :set_distributor, only: [:show, :edit, :update, :destroy]

  # GET /distributors
  # GET /distributors.json
  def index
    # @distributors = Distributor.all
    @distributors = ShopifyAPI::Customer.find(:all)
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
