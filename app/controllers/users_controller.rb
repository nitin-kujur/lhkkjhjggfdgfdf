class UsersController < ShopifyApp::AuthenticatedController
  def index
    @users = User.all
  end
end
