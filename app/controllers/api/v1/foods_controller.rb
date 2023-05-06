module Api
  module V1
    class FoodsController < ApplicationController
      def index
        # パラメーターのrestaurant_idを元にRestaurantからデータを特定して変数に代入
        restaurant = Restaurant.find(params[:restaurant_id])
        # restaurantのリレーションを使ってfoods一覧を取得して変数に代入
        foods = restaurant.foods

        # JSON形式でデータを返却、statusもOKで返す(200で返ってくる)
        render json: {
          foods: foods
        }, status: :ok
      end
    end
  end
end
