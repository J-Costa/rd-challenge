class RenameLineItemsToCartItems < ActiveRecord::Migration[7.1]
  def change
    rename_table :line_items, :cart_items
  end
end
