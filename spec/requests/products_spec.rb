require "rails_helper"

RSpec.describe "Products", type: :request do
  describe "GET /products" do
    it "returns a successful response and includes a link to new product" do
      get products_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("商品一覧")
      expect(response.body).to include(new_product_path)
    end

    it "shows all product attributes in index" do
      product = Product.create!(
        name: "Railsガイド",
        kind: :book,
        arrival_date: Date.new(2026, 2, 22),
        note: "初版"
      )

      get products_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.id.to_s)
      expect(response.body).to include(product.name)
      expect(response.body).to include("#{product.kind}(#{product.kind_before_type_cast})")
      expect(response.body).to include(product.arrival_date.to_s)
      expect(response.body).to include(product.note.to_s)
      expect(response.body).to include(product.created_at.in_time_zone("Tokyo").strftime("%Y-%m-%d %H:%M:%S %z"))
      expect(response.body).to include(product.updated_at.in_time_zone("Tokyo").strftime("%Y-%m-%d %H:%M:%S %z"))
    end
  end

  describe "GET /products/new" do
    it "returns a successful response and sets today as default arrival date" do
      get new_product_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("商品登録")
      expect(response.body).to include(%(value="#{Time.zone.today}"))
    end
  end

  describe "POST /products" do
    let(:valid_params) do
      {
        product: {
          name: "みかん",
          kind: "food",
          arrival_date: "2026-02-22",
          note: "和歌山産"
        }
      }
    end

    it "creates a product and redirects to index" do
      expect do
        post products_path, params: valid_params
      end.to change(Product, :count).by(1)

      expect(response).to redirect_to(products_path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("商品一覧")
    end

    it "returns 422 when name is blank" do
      invalid_params = valid_params.deep_dup
      invalid_params[:product][:name] = ""

      expect do
        post products_path, params: invalid_params
      end.not_to change(Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("商品名")
    end

    it "returns 422 when kind is blank" do
      invalid_params = valid_params.deep_dup
      invalid_params[:product][:kind] = ""

      expect do
        post products_path, params: invalid_params
      end.not_to change(Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("種類")
    end

    it "returns 422 when arrival date is blank" do
      invalid_params = valid_params.deep_dup
      invalid_params[:product][:arrival_date] = ""

      expect do
        post products_path, params: invalid_params
      end.not_to change(Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("入荷日")
    end
  end
end
