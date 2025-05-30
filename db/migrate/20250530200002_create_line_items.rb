class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items do |t|
      t.references :product, null: false, foreign_key: true
      t.references :cart, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :current_price, precision: 17, scale: 2, null: false

      t.timestamps
    end
  end
end
