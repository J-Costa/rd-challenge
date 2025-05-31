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

    context 'when the product is not in the cart' do
      subject(:response) do
        post '/cart/add_item', params: { product_id: new_product.id, quantity: 1 }, as: :json
      end

      let(:new_product) { Product.create(name: 'New Product', price: 20.0) }

      it 'adds the new product to the cart' do
        expect { response }.to change { cart.cart_items.count }.by(1)
        cart.reload
        expect(cart.cart_items.last.product).to eq(new_product)
        expect(cart.cart_items.last.quantity).to eq(1)
        expect(cart.total_price).to eq(cart.cart_items.sum('total_price'))
      end
    end

    context 'when the quantity is less than or equal to zero' do
      it 'returns an error' do
        post '/cart/add_item', params: { product_id: product.id, quantity: 0 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Quantity must be greater than 0')
      end
    end
  end

  describe 'DELETE :product_id' do
    let(:cart) { Cart.create(total_price: product.price, last_interaction_at: Time.current) }
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }
    let(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1, total_price: product.price) }

    before do
      allow_any_instance_of(CartsController).to receive(:session).and_return(cart_id: cart.id)
    end

    context 'when the product is in the cart' do
      it 'removes the item from the cart' do
        skip 'Fix the test to ensure it works with the current Cart model implementation'
      end
    end

    context 'when the product is not in the cart' do
      let(:non_existent_product) { Product.create(name: 'Non-existent Product', price: 15.0) }

      it 'returns an error' do
        delete remove_item_carts_path(non_existent_product)

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Product not found in cart')
      end
    end
  end
end
