class CartsController < ApplicationController
  include ApiErrorFormatter
  before_action :set_cart, only: %i[show add_item remove_item]

  def show
    render json: cart_body(@current_cart)
  end

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

  def add_item
    @current_cart.add_product!(cart_params[:product_id], cart_params[:quantity])
    render json: cart_body(@current_cart), status: :ok
  rescue ActiveRecord::ActiveRecordError => e
    render json: api_error_formatter(e), status: :unprocessable_entity
  end

  def remove_item
    @current_cart.remove_product!(product_param)

    render json: cart_body(@current_cart), status: :ok
  rescue ActiveRecord::ActiveRecordError => e
    render json: api_error_formatter(e), status: :unprocessable_entity
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
