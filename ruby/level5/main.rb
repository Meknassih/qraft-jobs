require 'json'
require 'date'
require_relative 'lib/rental'
require_relative 'lib/car'
require_relative 'lib/level_io'
require_relative 'lib/daily_option'

# Create new input/output handler
level_io = LevelIO.new('data/input.json', 'data/output.json')

# create all cars
cars = []
level_io.input['cars'].each do |car|
  cars.push(
    Car.new(
      id: car['id'],
      price_per_day: car['price_per_day'],
      price_per_km: car['price_per_km']
    )
  )
end

# create all options
options = []
level_io.input['options'].each do |option|
  options.push(
    DailyOption.new(
      id: option['id'],
      rental_id: option['rental_id'],
      type: option['type']
    )
  )
end

# for each rental calculate the cost
level_io.input['rentals'].each do |rental|
  # find the car used for this rental
  car_wanted = cars.select { |car| rental['car_id'] == car.id }
  raise 'Car not found' if car_wanted.empty?

  car_wanted = car_wanted[0]

  # find the options used for this rental
  options_wanted = options.select do |option|
    option.rental_id == rental['id']
  end

  # build the rental
  r = Rental.new(
    id: rental['id'],
    car: car_wanted,
    options: options_wanted,
    start_date: rental['start_date'],
    end_date: rental['end_date'],
    distance: rental['distance']
  )

  # push result in memory
  level_io.add_rental(r.id, r.options, r.actions)
end

# write and print the result as JSON to output.json in the expected structure
level_io.write_to_disk
puts level_io.json
