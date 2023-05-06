module Api
  module V1
    class LineFoodsController < ApplicationController
      # コールバックでset_foodをセットする
      before_action :set_food, only: %i[create]

      def create
        # すでに仮注文に入っているfoodのresutaurantのidを元として
        # other_restaurantスコープを実行して、他店舗のLineFoodがある場合の処理を開始(trueの時に実行される)
        if LineFood.active.other_restaurant(@ordered_food.restaurant.id)
          return render json: {
            # すでに仮注文に入っているfoodのrestaurantのnameを返却
            existing_restaurant: LineFood.other_restaurant(@ordered_food.restaurant.id).first.restaurant.name,
            # food_idを元に特定したFoodのrestaurantのnameを返却
            new_restaurant: Food.find(params[:food_id]).restaurant.name,
          }, status: :not_acceptable
          # HTTPレスポンスステータスコードは406(Not Acceptable)を返却
        end

        # 上記の条件に当てはまらない場合にはset_line_food関数を実行してLineFoodのインスタンスを作成
        set_line_food(@ordered_food)

        # set_line_foodメソッドによって作成された@line_foodインスタンスを保存する処理
        if @line_food.save
          # JSON形式でデータを返却、statusをcreated(201)で返す
          render json: {
            line_food: @line_food
          }, status: :created
          # 失敗時にはinternal_server_error(500)を返却
        else
          render json: {}, status: :internal_server_error
        end
      end

      private

      # food_idを元にFoodを一つ抽出して変数に格納
      def set_food
        @ordered_food = Food.find(params[:food_id])
      end

      def set_line_food(ordered_food)
        # ordered_foodがline_foodにすでに存在している場合
        if ordered_food.line_food.present?
          # ordered_foodのアソシエーションであるline_foodインスタンスを@line_food変数へ格納
          @line_food = ordered_food.line_food
          # @line_foodインスタンスのcountを足し合わせて既存の情報を更新する
          @line_food.attributes = {
            count: ordered_food.line_food.count + params[:count],
            active: true
          }
        else
        # 上記当てはまらない場合はordered_foodを元に関連付けメソッドを用いてインスタンスを作成し、
        # @line_foodというインスタンス変数に格納する
        # has_one - belongs_toだとparent.build_childという関連付けメソッドを使える
        @line_food = ordered_food.build_line_food(
          count: params[:count],
          restaurant: ordered_food.restaurant,
          active: true
        )
        end
      end
    end
  end
end