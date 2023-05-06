class LineFood < ApplicationRecord
  belongs_to :food
  belongs_to :restaurant
  # optionalをつけておくことで外部キーがnilであってもDBに保存できる
  belongs_to :order, optional: true

  validates :count, numericality: { greater_than: 0 }

  # activeカラムがtrueの箇所を絞り込む
  scope :active, -> { where(active: true) }
  # 引数にとったidが外部キーのrestaurant_idと一致しないレコードに絞り込む, 他の店舗のLineFoodがあるか否か？
  scope :other_restaurant, -> (picked_restaurant_id) { where.not(restaurant_id: picked_restaurant_id) }

  # LineFoodが持つfoodの金額と数量をかけて合計価格を算出するインスタンスメソッド
  def total_amount
    food.price * count
  end
end
