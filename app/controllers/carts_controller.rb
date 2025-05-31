class CartsController < ApplicationController
  before_action :create_cart, only: [:create]
  before_action :set_cart, only: %i[show add_item remove_item]

  def show
    render json: cart_body(@current_cart)
  end

  def create
    quantity = cart_params[:quantity].to_i
    if quantity <= 0
      return render json: { error: 'Quantity must be greater than 0' },
                    status: :unprocessable_entity
    end

    @current_cart.add_product(cart_params[:product_id], quantity)
    render json: cart_body(@current_cart), status: :created
  end

  def add_item
    quantity = cart_params[:quantity].to_i
    if quantity <= 0
      return render json: { error: 'Quantity must be greater than 0' },
                    status: :unprocessable_entity
    end

    @current_cart.add_product(cart_params[:product_id], quantity)
    render json: cart_body(@current_cart), status: :ok
  end

  def remove_item
    product_id = product_param
    product = @current_cart.products.find_by(id: product_id)
    return render json: { error: 'Product not found in cart' }, status: :not_found unless product

    @current_cart.remove_product(product.id)
    render json: cart_body(@current_cart), status: :ok
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
