class Rental
  attr_reader :id, :car, :start_date, :end_date, :distance

  def initialize(id:, car:, start_date:, end_date:, distance:)
    @id = id
    @car = car
    raise 'Car cannot be nil' if @car.nil?

    @start_date = Date.parse(start_date)
    @end_date = Date.parse(end_date)
    raise 'Invalid rental dates' if @start_date > @end_date

    @distance = distance.to_i
  end

  # returns the duration of the rental
  def duration_in_days
    # add 1 to take into account the starting day
    (end_date - start_date).to_i + 1
  end

  # compute discounted daily cost
  def discounted_daily_cost(nth_day)
    if nth_day == 1
      car.price_per_day
    elsif nth_day <= 4
      (car.price_per_day * 0.9).round
    elsif nth_day <= 10
      (car.price_per_day * 0.7).round
    else
      (car.price_per_day * 0.5).round
    end
  end

  # compute the distance cost
  def distance_cost
    distance * car.price_per_km
  end

  # compute the total cost with discounts
  def cost
    # start with fixed distance cost
    total = distance_cost
    # add each daily cost with its discount
    (1..duration_in_days).each do |day|
      total += discounted_daily_cost(day)
    end
    total
  end
end
