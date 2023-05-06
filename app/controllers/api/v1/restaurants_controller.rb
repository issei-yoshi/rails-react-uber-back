# moduleとすることで名前空間を指定することができる
module Api
  module V1
    class RestaurantsController < ApplicationController
      def index
        # Restaurantモデルを全て取得して変数に格納
        restaurants = Restaurant.all

        # JSON形式でデータを返却
        # リクエストが成功したことと200 OKと一緒にデータを返すよう指定
        render json: {
          restaurants: restaurants
        }, status: :ok
      end
    end
  end
end