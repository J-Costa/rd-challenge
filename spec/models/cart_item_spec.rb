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

    it 'validates numericality of current_price' do
      cart_item = described_class.new(quantity: 1, current_price: -1, product: product, cart: cart)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:current_price]).to include('must be greater than 0')
    end

    it 'validates presence of product' do
      cart_item = described_class.new(product: nil, quantity: 1, current_price: 100, cart: cart)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:product]).to include('must exist')
    end

    it 'validates presence of cart' do
      cart_item = described_class.new(cart: nil, quantity: 1, current_price: 100, product: product)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:cart]).to include('must exist')
    end
  end
end
