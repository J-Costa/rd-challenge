class CartsController < ApplicationController
  include ApiErrorFormatter

  before_action :set_cart, only: %i[show add_item remove_item]

  # rubocop:disable Layout/LineLength
  # @summary Visualizar o carrinho
  # @response Se o carrinho for localizado, retorna o carrinho (200) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Exemplo de carrinho  (200) [Hash] {id: 1, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # @response Se o carrinho não for localizado (404) [!Hash{errors: Array<Hash{type: String, message: String}>}]
  # @response_example Exemplo de carrinho não localizado (404) [Hash] {errors: [{type: 'Cart not found', message: 'Cart not found. Try to create one on POST /cart'}]}
  # rubocop:enable Layout/LineLength
  def show
    render json: cart_body(@current_cart)
  end

  # rubocop:disable Layout/LineLength
  # @summary Cria o carrinho e salva na sessão
  # @request_body Produto e quantidade para adicionar ao carrinho [!Hash{product_id: String, quantity: Integer }]
  # @request_body_example Produto e quantidades [Hash]{product_id: '1',quantity: 1}
  # @response Se o carrinho já existe, retorna o carrinho (200) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Retorna o carrinho existente (200) [Hash] {id: 1, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # @response Se o carrinho foi criado com sucesso, retorna o carrinho (201) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Exemplo de carrinho criado com sucesso (201) [Hash] {id: 1, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # @response Caso o produto não seja localizado (404) [!Hash{errors: Array<Hash{type: String, message: String}>}]
  # @response_example Exemplo de resposta (404) [Hash] {errors: [{type: 'Product not found', message: 'Could not find product with id `1`'}]}
  # @response Caso haja algum erro no payload (422) [!Hash{errors: Array<Hash{type: String, message: String}>}]
  # @response_example Exemplo de resposta (422) [Hash] {errors: [{type: 'Product error', message: 'Quantity must be greater than 0'}]}
  # rubocop:enable Layout/LineLength
  def create # rubocop:disable Metrics/AbcSize
    current_cart = Cart.find_by(id: session[:cart_id])
    if current_cart
      render json: cart_body(current_cart), status: :ok
    else
      Cart.transaction do
        current_cart = Cart.create!(total_price: 0, last_interaction_at: Time.current)
        current_cart.add_product!(cart_params[:product_id], cart_params[:quantity])
        session[:cart_id] = current_cart.id

        render json: cart_body(current_cart), status: :created
      end
    end
  rescue ActiveRecord::ActiveRecordError => e
    render json: api_error_formatter(e), status: :unprocessable_entity
  end

  # rubocop:disable Layout/LineLength
  # @summary Adicionar um item ao carrinho
  # @request_body Produto e quantidade para adicionar ao carrinho [!Hash{product_id: String, quantity: Integer }]
  # @request_body_example Produto e quantidades [Hash]{product_id: '1',quantity: 1}
  # @response Se o item foi adicionado com sucesso, retorna o carrinho atualizado (200) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Exemplo de carrinho atualizado (200) [Hash] {id: 1, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # @response Caso haja algum erro no payload ou o produto não foi localizado (422) [!Hash{errors: Array<Hash{type: String, message: String}>}]
  # @response_example Exemplo de resposta (422) [Hash] {errors: [{type: 'Product error', message: 'Quantity must be greater than 0'}]}
  # rubocop:enable Layout/LineLength
  def add_item
    @current_cart.add_product!(cart_params[:product_id], cart_params[:quantity])
    render json: cart_body(@current_cart), status: :ok
  rescue ActiveRecord::ActiveRecordError => e
    render json: api_error_formatter(e), status: :unprocessable_entity
  end

  # rubocop:disable Layout/LineLength
  # @summary remover um item ao carrinho
  # @parameter product_id(path) [!String] ID do produto a ser removido do carrinho
  # @response Se o item foi excluído com sucesso, retorna o carrinho (200) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Exemplo de carrinho atualizado(200) [Hash] {id: 1, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # @response Caso o id do produto não seja enviado (400) [!Hash{errors: Array<Hash{type: String, message: String}>}]
  # @response_example Exemplo de resposta (400) [Hash] {errors: [{type: 'Parameter missing', message: 'Product ID is required to remove an item from cart. Format: DELETE /cart/:product_id'}]}
  # @response Caso o produto não seja localizado (404) [!Hash{errors: Array<Hash{type: String, message: String}>}]
  # @response_example Exemplo de resposta (404) [Hash] {errors: [{type: 'Product not found', message: 'Product with id `123` not found in cart'}]}
  # rubocop:enable Layout/LineLength
  def remove_item
    @current_cart.remove_product!(product_param)

    render json: cart_body(@current_cart), status: :ok
  rescue ActiveRecord::ActiveRecordError => e
    render json: api_error_formatter(e), status: :unprocessable_entity
  end

  def render_missing_param
    render json: {
      errors: [{
        type: 'Parameter missing',
        message: 'Product ID is required to remove an item from cart. Format: DELETE /cart/:product_id'
      }]
    }, status: :bad_request
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def product_param
    params.require(:product_id)
  end

  def set_cart
    @current_cart = Cart.find_by(id: session[:cart_id])
    return if @current_cart

    render json: { errors: [{ type: 'Cart not found',
                              message: 'Cart not found. Try to create one on POST /cart' }] }, status: :not_found
  end

  def cart_body(cart)
    {
      id: cart.id,
      total_price: cart.total_price,
      products: cart.cart_items.map do |item|
        {
          id: item.product_id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.total_price
        }
      end
    }
  end
end
