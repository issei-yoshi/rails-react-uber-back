module Api
  module V1
    class OrdersController < ApplicationController
      def create
        # フロントから送られてくるidの配列を元にLineFoodモデルのレコードを取得して変数に代入
        posted_line_foods = LineFood.where(id: params[:line_food_ids])
        # total_priceカラムにtotal_priceメソッドを用いてorderインスタンスを作成
        order = Order.new(
          total_price: total_price(posted_line_foods)
        )

        # LineFoodモデルのレコードを変更する、save_with_update_line_foods!メソッドを呼び出す
        if order.save_with_update_line_foods!(posted_line_foods)
          # 成功した時には空データとstatus(204)を返却
          render json: {}, status: :no_content
        else
          # 失敗した時には空データとstatus(500)を返却
          render json: {}, status: :internal_server_error
        end
      end

      private

      # LineFoodモデルの複数レコードを一つ一つ展開してtotal_amountメソッドを用いて合計価格を算出
      # 算出した合計価格とrestaurantのfeeを合算して返すメソッド
      def total_price(posted_line_foods)
        posted_line_foods.sum {|line_food| line_food.total_amount } + posted_line_foods.first.restaurant.fee
      end
    end
  end
end