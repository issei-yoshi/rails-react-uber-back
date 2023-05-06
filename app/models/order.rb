class Order < ApplicationRecord
  has_many :line_foods

  validates :total_price, numericality: { greater_than: 0 }

  # 複数のLineFoodモデルのレコードを受け取り、activeカラムをfalseへと変更、
  # 外部キーとして持っているorderカラムを呼び出し元であるorderを入れるメソッド
  def save_with_update_line_foods!(line_foods)
    ActiveRecord::Base.transaction do
      line_foods.each do |line_food|
        line_food.update(active: false, order: self)
      end
      # 最後に呼び出し元のorderを保存する
      self.save!
    end
  end
end
