class ChangeDefaultValueForCartItems < ActiveRecord::Migration[7.1]
  def change
    change_column_default :cart_items, :quantity, from: 1, to: 0
  end
end
