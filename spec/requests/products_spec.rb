require "rails_helper"

RSpec.describe "Products", type: :request do
  describe "GET /products" do
    it "returns a successful response and includes a dialog trigger" do
      product = Product.create!(
        name: "みかん",
        kind: :food,
        arrival_date: Date.new(2026, 2, 23),
        note: "愛媛"
      )

      get products_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("商品一覧")
      expect(response.body).to include("commandfor=\"new-product-dialog\"")
      expect(response.body).to include("command=\"show-modal\"")
      expect(response.body).to include("id=\"new-product-dialog\"")
      expect(response.body).to include("command=\"close\"")
      expect(response.body).to include("formmethod=\"dialog\"")
      expect(response.body).to include(edit_product_path(product))
      expect(response.body).to include(delete_confirm_product_path(product))
      expect(response.body).to include("id=\"edit-product-dialog\"")
      expect(response.body).to include("id=\"delete-product-dialog\"")
      expect(response.body).not_to include("別ページで登録")
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
      expect(response.body).to include(product.kind_label)
      expect(response.body).to include(product.arrival_date.to_s)
      expect(response.body).to include(product.note.to_s)
      expect(response.body).to include(product.created_at.in_time_zone("Tokyo").strftime("%Y-%m-%d %H:%M:%S %z"))
      expect(response.body).to include(product.updated_at.in_time_zone("Tokyo").strftime("%Y-%m-%d %H:%M:%S %z"))
    end
  end

  describe "GET /products/:id/edit" do
    it "renders index with opened edit dialog and product values" do
      product = Product.create!(
        name: "Railsガイド",
        kind: :book,
        arrival_date: Date.new(2026, 2, 24),
        note: "第2版"
      )

      get edit_product_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/<dialog[^>]*id="edit-product-dialog"[^>]*open/)
      expect(response.body).to match(/id="edit-product-dialog"[^>]*class="[^"]*fixed[^"]*inset-0[^"]*z-50/)
      expect(response.body).to include(product.name)
      expect(response.body).to include(%(value="#{product.arrival_date}"))
      expect(response.body).to include(product.note)
      expect(response.body).to match(%r{<a[^>]*href="/products"[^>]*>キャンセル</a>})
      expect(response.body).to include("aria-label=\"背景をクリックして一覧へ戻る\"")
      expect(response.body).to include("aria-label=\"一覧へ戻る\"")
      expect(response.body).to include(">×</span>")
      expect(response.body).not_to match(%r{>一覧へ戻る</a>})
      expect(response.body).not_to match(/id="edit-product-dialog"[^>]*command="close"/)
    end
  end

  describe "GET /products/:id/delete_confirm" do
    it "renders index with opened delete dialog and confirmation actions" do
      product = Product.create!(
        name: "削除対象",
        kind: :food,
        arrival_date: Date.new(2026, 2, 24),
        note: "確認"
      )

      get delete_confirm_product_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/<dialog[^>]*id="delete-product-dialog"[^>]*open/)
      expect(response.body).to include("削除してよいですか？")
      expect(response.body).to match(%r{<a[^>]*href="/products"[^>]*>キャンセル</a>})
      expect(response.body).to include("action=\"#{product_path(product)}\"")
      expect(response.body).to include("name=\"_method\" value=\"delete\"")
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
      expect(response.body).to match(/<dialog[^>]*id="new-product-dialog"[^>]*open/)
      expect(response.body).to include("入力内容を確認してください")
      expect(response.body).to include("商品名")
    end

    it "returns 422 when kind is blank" do
      invalid_params = valid_params.deep_dup
      invalid_params[:product][:kind] = ""

      expect do
        post products_path, params: invalid_params
      end.not_to change(Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/<dialog[^>]*id="new-product-dialog"[^>]*open/)
      expect(response.body).to include("入力内容を確認してください")
      expect(response.body).to include("種類")
    end

    it "returns 422 when arrival date is blank" do
      invalid_params = valid_params.deep_dup
      invalid_params[:product][:arrival_date] = ""

      expect do
        post products_path, params: invalid_params
      end.not_to change(Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/<dialog[^>]*id="new-product-dialog"[^>]*open/)
      expect(response.body).to include("入力内容を確認してください")
      expect(response.body).to include("入荷日")
    end
  end

  describe "PATCH /products/:id" do
    let!(:product) do
      Product.create!(
        name: "旧商品名",
        kind: :food,
        arrival_date: Date.new(2026, 2, 25),
        note: "旧備考"
      )
    end

    let(:valid_params) do
      {
        product: {
          name: "新商品名",
          kind: "book",
          arrival_date: "2026-02-26",
          note: "新備考"
        }
      }
    end

    it "updates a product and redirects to index" do
      patch product_path(product), params: valid_params

      expect(response).to redirect_to(products_path)
      product.reload
      expect(product.name).to eq("新商品名")
      expect(product.kind).to eq("book")
      expect(product.arrival_date).to eq(Date.new(2026, 2, 26))
      expect(product.note).to eq("新備考")

      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("新商品名")
      expect(response.body).to include("書籍")
    end

    it "returns 422 and keeps edit dialog opened when invalid" do
      invalid_params = valid_params.deep_dup
      invalid_params[:product][:name] = ""

      patch product_path(product), params: invalid_params

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/<dialog[^>]*id="edit-product-dialog"[^>]*open/)
      expect(response.body).to include("入力内容を確認してください")
      expect(response.body).to include("商品名")
    end
  end

  describe "DELETE /products/:id" do
    it "destroys a product and redirects to index" do
      product = Product.create!(
        name: "削除される商品",
        kind: :miscellaneous,
        arrival_date: Date.new(2026, 2, 25),
        note: "削除確認"
      )

      expect do
        delete product_path(product)
      end.to change(Product, :count).by(-1)

      expect(response).to redirect_to(products_path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("削除される商品")
    end
  end
end
