module Carts
  class RemoveAbandonedJob < ApplicationJob
    queue_as :default

    def perform
      Cart.to_be_removed.find_each(batch_size: 1000, &:remove_if_abandoned)
    end
  end
end
