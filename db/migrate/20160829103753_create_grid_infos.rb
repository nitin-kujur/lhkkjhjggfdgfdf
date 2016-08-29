class CreateGridInfos < ActiveRecord::Migration
  def change
    create_table :grid_infos do |t|
      t.string :location_ids
      t.string :string
      t.string :product_ids
      t.string :string
      t.string :identifier

      t.timestamps null: false
    end
  end
end
