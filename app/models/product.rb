class Product < ApplicationRecord
  belongs_to :cart, optional: true

  validates :name, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
