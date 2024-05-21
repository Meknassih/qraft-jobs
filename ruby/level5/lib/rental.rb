class Rental
  attr_reader :id, :start_date, :end_date, :distance
  attr_accessor :car, :options

  Action = Struct.new(:who, :type, :amount)

  def initialize(id:, car:, options:, start_date:, end_date:, distance:)
    @id = id
    @car = car
    raise 'Car cannot be nil' if @car.nil?

    @start_date = Date.parse(start_date)
    @end_date = Date.parse(end_date)
    raise 'Invalid rental dates' if @start_date > @end_date

    @distance = distance.to_i
    @options = options
    raise 'options must be an array' unless @options.is_a?(Array)
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

  # compute days cost
  def days_cost
    total = 0
    (1..duration_in_days).each do |day|
      total += discounted_daily_cost(day)
    end
    total
  end

  # compute base cost which means without options
  def base_cost
    distance_cost + days_cost
  end

  # compute the total cost with discounts and options
  def driver_amount
    # start with fixed distance cost
    total = base_cost
    # add all options cost
    options.each do |option|
      total += option.cost(duration_in_days)
    end
    total
  end

  # compute parts of the 30% commission
  def commission
    { insurance_fee: insurance_fee, assistance_fee: assistance_fee, drivy_fee: drivy_fee }
  end

  def commission_amount
    (base_cost * 0.3).round
  end

  def owner_amount
    total = base_cost - commission_amount
    options.each do |option|
      total += option.cost(duration_in_days) if option.beneficiary == 'owner'
    end
    total
  end

  def insurance_fee
    (commission_amount / 2).round
  end

  def assistance_fee
    duration_in_days * 100
  end

  def drivy_fee
    total = commission_amount - insurance_fee - assistance_fee
    options.each do |option|
      total += option.cost(duration_in_days) if option.beneficiary == 'drivy'
    end
    total
  end

  # return all actions for this rental
  def actions
    [
      Action.new(who: 'driver', type: 'debit', amount: driver_amount),
      Action.new(who: 'owner', type: 'credit', amount: owner_amount),
      Action.new(who: 'insurance', type: 'credit', amount: commission[:insurance_fee]),
      Action.new(who: 'assistance', type: 'credit', amount: commission[:assistance_fee]),
      Action.new(who: 'drivy', type: 'credit', amount: commission[:drivy_fee])
    ]
  end
end
