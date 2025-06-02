class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  def update_total_price
    self.total_price = product.price * quantity
  end

  def increase_quantity!(amount)
    if amount.nil? || !amount.is_a?(Numeric)
      errors.add(:quantity, 'must be a number')
      raise ActiveRecord::RecordInvalid, self
    end

    if amount <= 0
      errors.add(:quantity, 'must be greater than 0')
      raise ActiveRecord::RecordInvalid, self
    end

    self.quantity += amount
    update_total_price

    save!
  end

  def remove_item
    self.quantity -= 1

    if quantity <= 0
      cart.cart_items.destroy(self)
      cart.update_total_price
    else
      update_total_price
      save
    end
  end
end
