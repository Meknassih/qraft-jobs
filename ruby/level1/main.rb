require 'json'
require 'date'

# read the input file
input_file = File.read('data/input.json')

# parse the input json
input = JSON.parse(input_file)

# declare array for computed prices
output = []

# for each rental calculate the price
input['rentals'].each do |rental|
  # find the car used for this rental
  car_wanted = input['cars'].select { |car| rental['car_id'] == car['id'] }
  raise 'Car not found' if car_wanted.empty?

  car_wanted = car_wanted[0].to_h

  # compute total rental days, assuming a rental must be at least 1 day and includes
  # starting and ending days
  total_days = Date.parse(rental['end_date']).mjd - Date.parse(rental['start_date']).mjd + 1
  raise 'Invalid rental dates' if total_days <= 0

  # price = SUM(days * priceperday, kms * priceperkm)
  total_cost = (total_days * car_wanted['price_per_day']) + (rental['distance'] * car_wanted['price_per_km'])

  # push result in memory
  output << {
    id: rental['id'], price: total_cost
  }
end

# write the result as JSON to output.json in the expected structure
output_json = JSON.pretty_generate({ rentals: output })
output_file = File.open('data/output.json', 'w')
bytes_written = output_file.write(output_json)
output_file.close
puts "#{bytes_written} bytes written"
