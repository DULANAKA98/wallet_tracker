class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.text :description
      t.string :image_url
      t.integer :external_id

      t.timestamps
    end
    add_index :products, :external_id, unique: true
  end
end
