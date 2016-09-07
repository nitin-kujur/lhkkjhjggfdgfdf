class CreateProductQuantities < ActiveRecord::Migration
  def change
    create_table :product_quantities do |t|
      t.integer :first_quantity
      t.integer :last_quantity
      t.float :price
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
