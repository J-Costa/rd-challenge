require 'rails_helper'

RSpec.describe '/carts' do
  describe 'POST /add_item' do
    let(:cart) { Cart.create(total_price: 0, last_interaction_at: Time.current) }
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1, total_price: product.price) }

    before do
      allow_any_instance_of(CartsController).to receive(:session).and_return(cart_id: cart.id)
    end

    context 'when the product already is in the cart' do
      subject(:response) do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { response }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
