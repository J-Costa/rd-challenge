require 'rails_helper'

RSpec.describe LineItem, type: :model do
  context 'when validating' do
    let(:cart) { carts(:one) }
    let(:product) { products(:s24) }

    it 'validates numericality of quantity' do
      line_item = described_class.new(quantity: -1, product: product, cart: cart)
      expect(line_item.valid?).to be_falsey
      expect(line_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'validates numericality of current_price' do
      line_item = described_class.new(quantity: 1, current_price: -1, product: product, cart: cart)
      expect(line_item.valid?).to be_falsey
      expect(line_item.errors[:current_price]).to include("must be greater than 0")
    end

    it 'validates presence of product' do
      line_item = described_class.new(product: nil, quantity: 1, current_price: 100, cart: cart)
      expect(line_item.valid?).to be_falsey
      expect(line_item.errors[:product]).to include('must exist')
    end

    it 'validates presence of cart' do
      line_item = described_class.new(cart: nil, quantity: 1, current_price: 100, product: product)
      expect(line_item.valid?).to be_falsey
      expect(line_item.errors[:cart]).to include('must exist')
    end
  end
end
