class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :distributor, index: true, foreign_key: true
      t.string :address1
      t.string :city
      t.string :province
      t.string :phone
      t.string :zip
      t.string :last_name
      t.string :first_name
      t.string :country

      t.timestamps null: false
    end
  end
end
