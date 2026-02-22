class Product < ApplicationRecord
  enum :kind, {
    food: 0,
    miscellaneous: 1,
    book: 2
  }

  validates :name, presence: true
  validates :kind, presence: true
  validates :arrival_date, presence: true
end
