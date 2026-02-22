class ProductsController < ApplicationController
  def index
    prepare_index_state
  end

  def new
    @product = Product.new(arrival_date: Time.zone.today)
  end

  def edit
    prepare_index_state
    @edit_product = Product.find(params[:id])
    @open_edit_dialog = true
    render :index
  end

  def create
    @new_product = Product.new(product_params)
    return redirect_to(products_path) if @new_product.save

    if form_source != "index_dialog"
      @product = @new_product
      return render :new, status: :unprocessable_content
    end

    prepare_index_state
    @open_new_product_dialog = true
    render :index, status: :unprocessable_content
  end

  def update
    @edit_product = Product.find(params[:id])
    if @edit_product.update(product_params)
      redirect_to products_path
    else
      prepare_index_state
      @open_edit_dialog = true
      render :index, status: :unprocessable_content
    end
  end

  private

  def product_params
    params.expect(product: %i[name kind arrival_date note])
  end

  def prepare_index_state
    @products = Product.order(created_at: :desc)
    @new_product = Product.new(arrival_date: Time.zone.today) unless defined?(@new_product)
  end

  def form_source
    params[:form_source]
  end
end
