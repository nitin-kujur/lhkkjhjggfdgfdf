class AddColumnShopifyIdToDistributors < ActiveRecord::Migration
  def change
  	add_column :distributors, :shopify_id, :string
  end
end
