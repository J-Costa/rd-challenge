class LineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :current_price, presence: true, numericality: { greater_than: 0 }
end