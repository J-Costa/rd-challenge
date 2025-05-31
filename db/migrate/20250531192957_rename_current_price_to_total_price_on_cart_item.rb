class RenameCurrentPriceToTotalPriceOnCartItem < ActiveRecord::Migration[7.1]
  def change
    rename_column :cart_items, :current_price, :total_price
  end
end
