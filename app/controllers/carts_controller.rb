class CartsController < ApplicationController
  before_action :create_cart, only: [:create]
  before_action :set_cart, only: %i[show add_item remove_item]

  def show
    render json: cart_body(@current_cart)
  end

  def create
    @current_cart.add_product(cart_params[:product_id], cart_params[:quantity].to_i)
    render json: cart_body(@current_cart), status: :created
  end

  def add_item
    @current_cart.add_product(cart_params[:product_id], cart_params[:quantity].to_i)
    render json: cart_body(@current_cart), status: :ok
  end

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
