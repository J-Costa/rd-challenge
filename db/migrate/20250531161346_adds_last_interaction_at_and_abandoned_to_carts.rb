class AddsLastInteractionAtAndAbandonedToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :last_interaction_at, :datetime, null: false
    add_column :carts, :abandoned, :boolean, default: false, null: false
  end
end
