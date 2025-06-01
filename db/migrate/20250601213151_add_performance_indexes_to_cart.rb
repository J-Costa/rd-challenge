class AddPerformanceIndexesToCart < ActiveRecord::Migration[7.1]
  def change
    add_index :carts, :last_interaction_at, name: 'index_carts_active_by_last_interaction', where: 'abandoned = false'
    add_index :carts, :last_interaction_at, name: 'index_carts_abandoned_by_last_interaction', where: 'abandoned = true'
    add_index :carts, [:id, :abandoned, :last_interaction_at], name: 'index_carts_covering_for_jobs'
  end
end
