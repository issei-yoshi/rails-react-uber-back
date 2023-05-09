module Api
  module V1
    class LineFoodsController < ApplicationController
      # コールバックでset_foodをセットする
      before_action :set_food, only: %i[create replace]

      def create
        # すでに仮注文に入っているfoodのresutaurantのidを元として
        # other_restaurantスコープを実行して、他店舗のLineFoodがある場合の処理を開始(trueの時に実行される)
        if LineFood.active.other_restaurant(@ordered_food.restaurant.id).exists?
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

      def index
        # LineFoodモデルの中からactiveカラムがtrueのものを取得して代入
        line_foods = LineFood.active
        # LineFoodモデルの中にactiveカラムがtrueのものが存在する場合
        if line_foods.exists?
          # JSON形式でデータを返却、statusもOK(200)で返す
          render json: {
            # LineFoodモデルに登録されているactiveなレコードのすべてのIDを配列にして返却
            line_food_ids: line_foods.map { |line_food| line_food.id },
            # LineFoodモデルに登録されているactiveなレコードの1つ目のrestaurant情報を返却
            restaurant: line_foods[0].restaurant,
            # 登録されているactiveなレコードのすべてのcountカラムを足し合わせてcountとして返却
            count: line_foods.sum { |line_food| line_food[:count] },
            # total_amountメソッドを用いて、登録されているactiveなレコードの合計金額をamountとして返却
            amount: line_foods.sum { |line_food| line_food.total_amount },
          }, status: :ok
        else
          # activeなLineFoodが存在しない場合にはstatus(204)を返す
          # リクエストは成功しているが空データの場合のstatusコード
          render json: {}, status: :no_content
        end
      end

      def replace
        # active且つ他店舗のLineFoodモデルのデータの一つ一つのactiveカラムをfalseへと更新
        # 他店舗のactiveなLineFood一覧
        LineFood.active.other_restaurant(@ordered_food.restaurant.id).each do |line_food|
          line_food.update(active: false)
        end

        # set_line_food関数を実行してLineFoodのインスタンスを作成
        set_line_food(@ordered_food)

        # 成功したら@line_foodとstatusをcreated(201)で返す
        if @line_food.save
          render json: {
            line_food: @line_food
          }, status: :created
        else
          # 失敗時にはinternal_server_error(500)を返却
          render json: {}, status: :internal_server_error
        end
      end

      private

      # food_idを元にFoodを一つ抽出して変数に格納
      def set_food
        @ordered_food = Food.find(params[:food_id])
      end

      # LineFoodモデルを作成するメソッド
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