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

  context 'when increasing quantity' do
    let(:cart) { carts(:with_items) }
    let(:product) { cart.products.first }
    let(:cart_item) { cart.cart_items.first }

    it 'increases the quantity by the specified amount' do
      expect(cart_item.quantity).to eq(1)
      expect { cart_item.increase_quantity!(2) }.to change(cart_item, :quantity).by(2)
      expect(cart_item.quantity).to eq(3)
      expect(cart_item.total_price).to eq(product.price * 3)
    end

    it 'raises an error if the amount is not a number' do
      expect { cart_item.increase_quantity!('invalid') }.to raise_error(ActiveRecord::RecordInvalid)
      expect(cart_item.errors[:quantity]).to include('must be a number')
    end

    it 'raises an error if the amount is less than or equal to 0' do
      expect { cart_item.increase_quantity!(0) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(cart_item.errors[:quantity]).to include('must be greater than 0')
    end
  end
end
