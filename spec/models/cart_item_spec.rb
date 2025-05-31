require 'rails_helper'

RSpec.describe CartItem do
  context 'when validating' do
    let(:cart) { carts(:without_items) }
    let(:product) { products(:s24) }

    it 'validates numericality of quantity' do
      cart_item = described_class.new(quantity: -1, product: product, cart: cart)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include('must be greater than 0')
    end

    it 'validates numericality of total_price' do
      cart_item = described_class.new(quantity: 1, total_price: -1, product: product, cart: cart)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:total_price]).to include('must be greater than 0')
    end

    it 'validates presence of product' do
      cart_item = described_class.new(product: nil, quantity: 1, total_price: 100, cart: cart)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:product]).to include('must exist')
    end

    it 'validates presence of cart' do
      cart_item = described_class.new(cart: nil, quantity: 1, total_price: 100, product: product)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:cart]).to include('must exist')
    end
  end

  context 'when removing items' do
    subject(:cart_item) { described_class.create(cart: carts(:without_items), product: product, quantity: 2, total_price: 200) }

    let(:product) { Product.create(name: 'Test Product', price: 100.0) }

    it 'decreases the quantity by 1' do
      expect { cart_item.remove_item }.to change(cart_item, :quantity).by(-1)
      expect(cart_item.total_price).to eq(100.0)
    end

    it 'removes the item if quantity reaches 0' do
      cart_item.quantity = 1
      expect { cart_item.remove_item }.to change(described_class, :count).by(-1)
      expect(cart_item.cart.cart_items).not_to include(cart_item)
    end
  end
end
