class CartsController < ApplicationController
  before_action :create_cart, only: [:create]
  before_action :set_cart, only: %i[show add_item remove_item]

  def show
    render json: cart_body(@current_cart)
  end

  # rubocop:disable Layout/LineLength
  # @summary Cria ou atualiza o carrinho e salva na sessão
  # @request_body Produto para adicionar ao carrinho [!Hash{product_id: String, quantity: Integer }]
  # @request_body_example Produto e quantidades [Hash]{product_id: '475308017',quantity: 1}
  # @response Se o carrinho foi criado com sucesso, retorna o carrinho (201) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Exemplo de carrinho criado com sucesso (201) [Hash] {id: 475308017, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # rubocop:enable Layout/LineLength
  def create
    @current_cart.add_product(cart_params[:product_id], cart_params[:quantity].to_i)
    render json: cart_body(@current_cart), status: :created
  end

  # rubocop:disable Layout/LineLength
  # @summary Adicionar um item ao carrinho
  # @request_body Produto para adicionar ao carrinho [!Hash{product_id: String, quantity: Integer }]
  # @request_body_example Produto e quantidades [Hash]{product_id: '475308017',quantity: 1}
  # @response Se o item foi adicionado com sucesso, retorna o carrinho atualizado (200) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Exemplo de carrinho atualizado (200) [Hash] {id: 1, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # rubocop:enable Layout/LineLength
  def add_item
    @current_cart.add_product(cart_params[:product_id], cart_params[:quantity].to_i)
    render json: cart_body(@current_cart), status: :ok
  end

  # rubocop:disable Layout/LineLength
  # @summary remover um item ao carrinho
  # @param product_id [String] ID do produto a ser removido do carrinho
  # @response Se o item foi excluído com sucesso, retorna o carrinho (200) [!Hash{id: Integer, total_price: Float, products: Array<Hash{id: String, name: String, quantity: Integer, unit_price: Float, total_price: Float}>}]
  # @response_example Exemplo de carrinho atualizado(200) [Hash] {id: 1, total_price: 100.0, products: [{id: '12345', name: 'Product Name', quantity: 2, unit_price: 50.0, total_price: 100.0}]}
  # response Se o produto não foi encontrado no carrinho, retorna erro (404) [!Hash{error: String}]
  # @response_example Exemplo de erro ao remover produto(404) [Hash] {error: 'Product not found in cart'}
  # rubocop:enable Layout/LineLength
  def remove_item
    product_id = product_param
    cart_item = @current_cart.cart_items.find_by(product_id: product_id)

    if cart_item
      cart_item.remove_item
      render json: cart_body(@current_cart), status: :ok
    else
      render json: { error: 'Product not found in cart' }, status: :not_found
    end
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def product_param
    params.require(:product_id)
  end

  def create_cart
    @current_cart = Cart.find_by(id: session[:cart_id])
    return session[:cart_id] = @current_cart.id if @current_cart

    @current_cart = Cart.create(total_price: 0, last_interaction_at: Time.current)
    session[:cart_id] = @current_cart.id
  end

  def set_cart
    @current_cart = Cart.find_by(id: session[:cart_id])
    return if @current_cart

    render json: { error: 'Cart not found' }, status: :not_found
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
