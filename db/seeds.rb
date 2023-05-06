3.times do |n|
  restaurant = Restaurant.new(
    name: "testレストラン_#{n}",
    fee: 100,
    time_required: 10,
  )

  12.times do |m|
    restaurant.foods.build(
      name: "#{n}_フード#{m}",
      price: 500,
      description: "#{n}_フード#{m}のdescription"
    )
  end

  restaurant.save!
end