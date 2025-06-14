class MarkCartAsAbandonedJob
  include Sidekiq::Job
  queue_as :default

  def perform
    Cart.without_interaction.find_each(batch_size: 1000, &:mark_as_abandoned)
  end
end
