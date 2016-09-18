class AddColumnToProductLeadTime < ActiveRecord::Migration
  def change
  	add_column :products, :lead_time, :string
  end
end
