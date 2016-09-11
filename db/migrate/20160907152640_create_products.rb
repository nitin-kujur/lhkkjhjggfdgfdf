class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :shopify_product_id
      t.integer :min_quantity
      t.references :shop

      t.timestamps null: false
    end
  end
end
