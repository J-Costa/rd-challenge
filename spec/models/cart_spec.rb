require 'rails_helper'

RSpec.describe Cart do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart).not_to be_valid
      expect(cart.errors[:total_price]).to include('must be greater than or equal to 0')
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { carts(:with_items) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change(shopping_cart, :abandoned?).from(false).to(true)
    end

    it 'does not mark the shopping cart as abandoned if already abandoned' do
      shopping_cart.update(last_interaction_at: 3.hours.ago, abandoned: true)
      expect { shopping_cart.mark_as_abandoned }.not_to change(shopping_cart.reload, :abandoned?)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { carts(:with_items).tap { |cart| cart.update(last_interaction_at: 7.days.ago) } }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change(described_class, :count).by(-1)
    end
  end

  context 'when adding products' do
    subject(:cart) { described_class.create(total_price: 0, last_interaction_at: Time.current) }

    let(:product) { Product.create(name: 'Test Product', price: 10.0) }

    it 'adds a product to the cart' do
      expect { cart.add_product!(product.id, 2) }.to change { cart.cart_items.count }.by(1)

      expect(cart.cart_items.first.product).to eq(product)
      expect(cart.cart_items.first.quantity).to eq(2)
      expect(cart.total_price).to eq(20.0)
    end

    it 'updates the quantity of an existing product in the cart' do
      cart.add_product!(product.id, 1)
      expect { cart.add_product!(product.id, 2) }.to change { cart.cart_items.first.quantity }.by(2)

      expect(cart.cart_items.first.quantity).to eq(3)
      expect(cart.total_price).to eq(30.0)
    end

    context 'when adding a product with invalid data' do
      it 'raises an error when trying to add a product that does not exist' do
        expect { cart.add_product!(999, 1) }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Product with 'id'=999")
      end

      it 'raises an error when trying to add a product with invalid quantity' do
        expect { cart.add_product!(product.id, 0) }.to raise_error do |error|
          expect(error).to be_a(ActiveRecord::RecordInvalid)
          expect(error.message).to include('Quantity must be greater than 0')
          expect(error.record.errors[:quantity]).to include('must be greater than 0')
        end
      end
    end
  end

  context 'when removing products' do
    subject(:cart) { described_class.create(total_price: 0, last_interaction_at: Time.current) }

    let(:product) { Product.create(name: 'Test Product', price: 10.0) }

    before do
      cart.add_product!(product.id, 2)
    end

    it 'updates quantity and total price when more than one quantity' do
      cart_last_interaction = cart.last_interaction_at
      expect { cart.remove_product!(product.id) }.not_to(change { cart.cart_items.count })

      expect(cart.reload.last_interaction_at).to be > cart_last_interaction
      expect(cart.cart_items.count).to eq(1)
      expect(cart.total_price).to eq(10.0)
    end

    it 'destroy cart_item when only have one quantity' do
      cart.remove_product!(product.id)
      cart_last_interaction = cart.last_interaction_at

      expect { cart.remove_product!(product.id) }.to change { cart.cart_items.count }.by(-1)

      expect(cart.reload.last_interaction_at).to be > cart_last_interaction
      expect(cart.cart_items.count).to eq(0)
      expect(cart.total_price).to eq(0)
    end

    it 'does not remove a product that is not in the cart' do
      another_product = Product.create(name: 'Another Product', price: 15.0)
      expect { cart.remove_product!(another_product.id) }.to raise_error(ActiveRecord::RecordNotFound, "Product with id `#{another_product.id}` not found in cart")
    end
  end

  context 'with scopes' do
    let!(:abandoned_cart) { described_class.create(total_price: 0, last_interaction_at: described_class::HOURS_TO_ABANDON.hours.ago, abandoned: false) }
    let!(:active_cart) { described_class.create(total_price: 0, last_interaction_at: Time.current, abandoned: false) }
    let!(:old_abandoned_cart) { described_class.create(total_price: 0, last_interaction_at: described_class::DAYS_TO_REMOVE.days.ago, abandoned: true) }

    describe '.without_interaction' do
      it 'returns carts without interaction for more than 3 hours' do
        expect(described_class.without_interaction).to include(abandoned_cart)
        expect(described_class.without_interaction).not_to include(active_cart)
      end
    end

    describe '.to_be_removed' do
      it 'returns abandoned carts older than 7 days' do
        expect(described_class.to_be_removed).to include(old_abandoned_cart)
        expect(described_class.to_be_removed).not_to include(abandoned_cart)
      end
    end
  end
end
