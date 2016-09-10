class ProductsController < ShopifyApp::AuthenticatedController
  before_action :set_session
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @shipify_products = ShopifyAPI::Product.find(:all)
    @products = Product.all
    shop = Shop.find_by_shopify_domain(params[:shop])
    @shipify_products.each do |sp|
      unless @products.map(&:shopify_product_id).include?(sp.id.to_s)
        @products << Product.create(shopify_product_id: sp.id, shop_id: shop.id)
      end
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:shopify_product_id, :min_quantity, product_quantities_attributes: [:id, :first_quantity, :last_quantity, :price, :_destroy])
    end
    def set_session
      params[:shop] = 'pepsi-test.myshopify.com' if params[:shop].blank? && Rails.env.development?
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
