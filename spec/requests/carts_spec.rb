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
        post add_item_carts_path, params: { product_id: product.id, quantity: 1 }, as: :json
        post add_item_carts_path, params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { response }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context 'when the product is not in the cart' do
      subject(:response) do
        post add_item_carts_path, params: { product_id: new_product.id, quantity: 1 }, as: :json
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

    context 'when request is successful' do
      before do
        post add_item_carts_path, params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end

      it 'returns cart data with correct structure' do
        parsed_response = response.parsed_body
        expect(parsed_response).to include(
          'id' => cart.id,
          'total_price' => cart.reload.total_price.to_s,
          'products' => be_an(Array)
        )

        product_data = parsed_response['products'].find { |p| p['id'] == product.id }
        expect(product_data).to include(
          'id' => product.reload.id,
          'name' => product.name,
          'quantity' => 2,
          'unit_price' => product.price.to_s,
          'total_price' => (product.price * 2).to_s
        )
      end
    end

    context 'when the quantity is less than or equal to zero' do
      it 'returns an error' do
        post add_item_carts_path, params: { product_id: product.id, quantity: 0 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Quantity must be greater than 0')
      end
    end

    context 'when the quantity is null' do
      it 'returns an error' do
        post add_item_carts_path, params: { product_id: product.id, quantity: nil }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Quantity must be a number')
      end
    end

    context 'when the quantity is a not a number' do
      it 'returns an error' do
        post add_item_carts_path, params: { product_id: product.id, quantity: 'one' }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Quantity must be a number')
      end
    end
  end

  describe 'DELETE :product_id' do
    let(:product) { Product.create!(name: 'Test Product', price: 10.0) }
    let(:cart) { Cart.create!(total_price: product.price, last_interaction_at: Time.current) }
    let!(:cart_item) { CartItem.create!(cart: cart, product: product, quantity: 1, total_price: product.price) }

    before do
      allow_any_instance_of(CartsController).to receive(:session).and_return(cart_id: cart.id)
    end

    context 'when the product is in the cart' do
      it 'removes the item from the cart' do
        delete remove_item_carts_path(product)

        expect(response).to have_http_status(:success)
        expect(cart.reload.cart_items.count).to eq(0)
        expect(cart.reload.total_price).to eq(0.0)
      end
    end

    context 'when the product is not in the cart' do
      let(:non_existent_product) { Product.create(name: 'Non-existent Product', price: 15.0) }

      it 'returns a product not found' do
        expect(cart.cart_items.where(product_id: non_existent_product.id)).to be_empty

        delete remove_item_carts_path(non_existent_product)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Product not found')
      end
    end

    context 'when the product_id is not provided' do
      it 'returns a bad request response' do
        delete '/cart/'

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Product ID is required to remove an item from cart')
      end
    end
  end

  describe 'POST cart/' do
    context 'when cart for session does not exists' do
      context 'when payload is valid' do
        before do
          post carts_path, params: { product_id: product.id, quantity: 1 }, as: :json
        end

        let(:product) { products(:s24) }

        it 'returns a created response' do
          expect(response).to have_http_status(:created)
        end

        it 'creates a new cart with the product' do
          cart = Cart.last
          expect(cart.total_price).to eq(product.price)
          expect(cart.cart_items.count).to eq(1)
          expect(cart.cart_items.first.product).to eq(product)
          expect(cart.cart_items.first.quantity).to eq(1)
        end

        it 'returns cart data' do
          parsed_response = response.parsed_body
          cart = Cart.find(parsed_response['id'])
          expect(parsed_response).to include(
            'id' => cart.id,
            'total_price' => cart.total_price.to_s,
            'products' => be_an(Array)
          )

          product_data = parsed_response['products'].find { |p| p['id'] == product.id }
          expect(product_data).to include(
            'id' => product.reload.id,
            'name' => product.name,
            'quantity' => 1,
            'unit_price' => product.price.to_s,
            'total_price' => (product.price * 1).to_s
          )
        end
      end

      context 'when product_id is invalid' do
        let(:invalid_product_id) { -1 }

        before do
          post carts_path, params: { product_id: invalid_product_id, quantity: 1 }, as: :json
        end

        it 'returns an unprocessable entity response' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns an error message' do
          expect(response.body).to include('Product not found')
        end
      end

      context 'when quantity is less than or equal to zero' do
        let(:product) { products(:s24) }

        before do
          post carts_path, params: { product_id: product.id, quantity: 0 }, as: :json
        end

        it 'returns an unprocessable entity response' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns an error message' do
          expect(response.body).to include('Quantity must be greater than 0')
        end
      end
    end

    context 'when cart for session already exists' do
      let(:cart) { Cart.create!(total_price: 10.0, last_interaction_at: Time.current) }
      let(:product) { Product.create!(name: 'Test Product', price: 10.0) }
      let!(:cart_item) { CartItem.create!(cart: cart, product: product, quantity: 1, total_price: product.price) }

      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return(cart_id: cart.id)
        post carts_path, params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:success)
      end

      it 'adds the product to the existing cart' do
        expect(cart.cart_items.count).to eq(1)
        expect(cart_item.product).to eq(product)
        expect(cart_item.quantity).to eq(1)
        expect(cart.total_price).to eq(product.price)
      end
    end
  end

  describe 'GET /cart' do
    context 'when cart for session exists' do
      let(:cart) { Cart.create!(total_price: 0, last_interaction_at: Time.current) }
      let(:product) { Product.create!(name: 'Test Product', price: 10.0) }
      let!(:cart_item) { CartItem.create!(cart: cart, product: product, quantity: 1, total_price: product.price) }

      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return(cart_id: cart.id)
        get carts_path
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the cart data' do
        parsed_response = response.parsed_body
        expect(parsed_response).to include(
          'id' => cart.id,
          'total_price' => cart.total_price.to_s,
          'products' => be_an(Array)
        )

        product_data = parsed_response['products'].find { |p| p['id'] == product.id }
        expect(product_data).to include(
          'id' => product.id,
          'name' => product.name,
          'quantity' => 1,
          'unit_price' => product.price.to_s,
          'total_price' => product.price.to_s
        )
      end
    end

    context 'when cart for session does not exist' do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return(cart_id: nil)
        get carts_path
      end

      it 'returns a not found response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(response.body).to include('Cart not found')
      end
    end
  end
end
