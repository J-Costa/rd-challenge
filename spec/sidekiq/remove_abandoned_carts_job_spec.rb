require 'rails_helper'

RSpec.describe RemoveAbandonedCartsJob, type: :job do
  describe '#perform' do
    let!(:recent_abandoned_cart) do
      Cart.create(
        total_price: 25.0,
        last_interaction_at: 3.days.ago,
        abandoned: true
      )
    end

    let!(:old_abandoned_cart) do
      Cart.create(
        total_price: 50.0,
        last_interaction_at: 8.days.ago,
        abandoned: true
      )
    end

    let!(:very_old_abandoned_cart) do
      Cart.create(
        total_price: 75.0,
        last_interaction_at: 10.days.ago,
        abandoned: true
      )
    end

    let!(:active_cart) do
      Cart.create(
        total_price: 100.0,
        last_interaction_at: 1.hour.ago,
        abandoned: false
      )
    end

    let!(:recent_active_cart) do
      Cart.create(
        total_price: 30.0,
        last_interaction_at: 5.days.ago,
        abandoned: false
      )
    end

    context 'when performing the job' do
      it 'removes old abandoned carts' do
        expect { described_class.new.perform }.to change(Cart, :count).by(-2)
      end

      it 'does not remove recent abandoned carts' do
        described_class.new.perform

        expect { recent_abandoned_cart.reload }.not_to raise_error
        expect(recent_abandoned_cart.reload).to be_persisted
      end

      it 'does not remove active carts regardless of age' do
        described_class.new.perform

        expect { active_cart.reload }.not_to raise_error
        expect { recent_active_cart.reload }.not_to raise_error
      end

      it 'removes only carts that meet both conditions: abandoned and old' do
        described_class.new.perform

        expect { old_abandoned_cart.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { very_old_abandoned_cart.reload }.to raise_error(ActiveRecord::RecordNotFound)

        expect(recent_abandoned_cart.reload).to be_persisted
        expect(active_cart.reload).to be_persisted
        expect(recent_active_cart.reload).to be_persisted
      end
    end

    context 'when testing with cart items' do
      let!(:cart_with_items) do
        cart = Cart.create(
          total_price: 200.0,
          last_interaction_at: 8.days.ago,
          abandoned: true
        )

        product = Product.create(name: 'Test Product', price: 50.0)
        CartItem.create(
          cart: cart,
          product: product,
          quantity: 4,
          total_price: 200.0
        )

        cart
      end

      it 'removes cart and associated cart items' do
        expect { described_class.new.perform }.to change(Cart, :count).by(-3).and change(CartItem, :count).by(-1)
      end

      it 'destroys cart items when cart is destroyed' do
        cart_item = cart_with_items.cart_items.first

        described_class.new.perform

        expect { cart_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when no carts qualify for removal' do
      before do
        Cart.to_be_removed.destroy_all
      end

      it 'does not change cart count when no carts qualify' do
        expect { described_class.new.perform }.not_to change(Cart, :count)
      end

      it 'completes successfully with no qualifying carts' do
        expect { described_class.new.perform }.not_to raise_error
      end
    end
  end
end
