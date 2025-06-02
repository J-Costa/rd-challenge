class Cart < ApplicationRecord
  HOURS_TO_ABANDON = 3
  DAYS_TO_REMOVE = 7

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  scope :without_interaction, -> { where(abandoned: false, last_interaction_at: ...HOURS_TO_ABANDON.hours.ago) }
  scope :to_be_removed, -> { where(abandoned: true, last_interaction_at: ...DAYS_TO_REMOVE.days.ago) }

  def add_product!(product_id, quantity = 1)
    find_or_create_cart_item!(product_id, quantity)
    touch(:last_interaction_at)
    update_total_price
  end

  def remove_product!(product_id)
    cart_item = cart_items.find_by(product_id: product_id)
    raise ActiveRecord::RecordNotFound, "Product with id `#{product_id}` not found in cart" unless cart_item

    touch(:last_interaction_at)
    cart_item.remove_item
    update_total_price
  end

  def update_total_price
    self.total_price = cart_items.sum('total_price')
    save
  end

  def mark_as_abandoned
    return if abandoned? && last_interaction_at >= HOURS_TO_ABANDON.hours.ago

    self.abandoned = true
    save
  end

  def remove_if_abandoned
    return unless abandoned? && last_interaction_at < DAYS_TO_REMOVE.days.ago

    destroy
  end

  private

  def find_or_create_cart_item!(product_id, quantity)
    product = Product.find(product_id)
    cart_item = cart_items.find_or_create_by(product: product)

    cart_item.increase_quantity!(quantity)

    cart_item.update_total_price
    cart_item.save!
  end
end
