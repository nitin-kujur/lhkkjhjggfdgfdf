class DistributorsController < ApplicationController
  before_action :set_distributor, only: [:show, :edit, :update, :destroy]

  # GET /distributors
  # GET /distributors.json
  def index
    @distributors = Distributor.all
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
  	customer_hash= {
					  "customer": {
					    "first_name": "Steve",
					    "last_name": "Lastnameson",
					    "email": "arpitvaishnav@gmail.com",
					    "verified_email": true,
					    "addresses": [
					      {
					        "address1": "123 Oak St",
					        "city": "Ottawa",
					        "province": "ON",
					        "phone": "555-1212",
					        "zip": "123 ABC",
					        "last_name": "Lastnameson",
					        "first_name": "Mother",
					        "country": "CA"
					      }
					  #   , {
							# "address1": "12 Oak St",
					  #       "city": "Ottawa",
					  #       "province": "ON",
					  #       "phone": "555-121",
					  #       "zip": "123 ABC",
					  #       "last_name": "Lastnameson",
					  #       "first_name": "Mother",
					  #       "country": "CA"
					  #   	}
						]
					  }
					}
  	
    @distributor = Distributor.new(distributor_params)

    respond_to do |format|
      if @distributor.save
      	# custo_hash = 
      	byebug
        ShopifyAPI::Customer.create(distributor_params)
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
