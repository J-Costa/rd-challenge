require 'rails_helper'

RSpec.describe Product do
  context 'when validating' do
    it 'validates presence of name' do
      product = described_class.new(price: 100)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'validates presence of price' do
      product = described_class.new(name: 'name')
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it 'validates numericality of price' do
      product = described_class.new(price: -1)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include('must be greater than or equal to 0')
    end
  end
end
