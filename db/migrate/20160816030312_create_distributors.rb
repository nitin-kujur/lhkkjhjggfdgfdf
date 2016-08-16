class CreateDistributors < ActiveRecord::Migration
  def change
    create_table :distributors do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :verified_email

      t.timestamps null: false
    end
  end
end
