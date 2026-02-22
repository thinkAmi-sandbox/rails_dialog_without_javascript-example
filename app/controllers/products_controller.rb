class ProductsController < ApplicationController
  def index
    @products = Product.order(created_at: :desc)
    @product = Product.new(arrival_date: Time.zone.today)
  end

  def new
    @product = Product.new(arrival_date: Time.zone.today)
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path
    elsif form_source == "index_dialog"
      @products = Product.order(created_at: :desc)
      @open_product_dialog = true
      render :index, status: :unprocessable_content
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def product_params
    params.expect(product: %i[name kind arrival_date note])
  end

  def form_source
    params[:form_source]
  end
end
