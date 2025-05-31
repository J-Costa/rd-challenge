class CartsController < ApplicationController 
  before_action :create_cart, only: [:create]
  before_action :set_cart, only: %i[show add_item]

  def show
    render json: @current_cart || { error: 'Cart not found' }, status: @current_cart ? :ok : :not_found
  end

  def create
    @current_cart.add_product(cart_params[:product_id], cart_params[:quantity].to_i)
    render json: @current_cart, status: :created
  end

  def add_item
    render json: { error: 'Cart not found' }, status: :not_found and return unless @current_cart

    @current_cart.add_product(cart_params[:product_id], cart_params[:quantity].to_i)
    render json: @current_cart, status: :ok
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def create_cart
    @current_cart = Cart.find_by(id: session[:cart_id])
    return session[:cart_id] = @current_cart.id if @current_cart

    @current_cart = Cart.create(total_price: 0)
    session[:cart_id] = @current_cart.id
  end

  def set_cart
    @current_cart = Cart.find_by(id: session[:cart_id])
    return if @current_cart

    render json: { error: 'Cart not found' }, status: :not_found
  end
end
