class Product < ApplicationRecord
  KIND_LABELS = {
    "food" => "食品",
    "miscellaneous" => "雑貨",
    "book" => "書籍"
  }.freeze

  enum :kind, {
    food: 0,
    miscellaneous: 1,
    book: 2
  }

  validates :name, presence: true
  validates :kind, presence: true
  validates :arrival_date, presence: true

  def kind_label
    KIND_LABELS.fetch(kind)
  end
end
