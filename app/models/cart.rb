class Cart < ApplicationRecord
  HOURS_TO_ABANDON = 3
  DAYS_TO_REMOVE = 7

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
  def add_product(product_id, quantity = 1)
    product = Product.find(product_id)
    cart_item = cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.quantity += quantity
    else
      cart_item = cart_items.build(product: product, quantity: quantity)
    end

    cart_item.update_current_price
    cart_item.save
    update_total_price
  end

  def update_total_price
    self.total_price = cart_items.sum('current_price')
    save
  end

  def mark_as_abandoned
    return if abandoned? && last_interaction_at >= HOURS_TO_ABANDON.hours.ago

    toggle(:abandoned)
    save
  end

  def remove_if_abandoned
    return unless abandoned? && last_interaction_at < 7.days.ago

    destroy
  end
end
