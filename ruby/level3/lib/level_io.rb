class LevelIO
  attr_reader :input, :output

  def initialize(input_path, output_path, initial_output = {})
    @input_file = File.read(input_path)
    @input = JSON.parse(@input_file)
    @output_file = File.open(output_path, 'w')
    @output = initial_output
  end

  def add_rental_cost(id, cost, commission)
    output['rentals'] = [] if output['rentals'].nil?
    output['rentals'].push({ id: id, price: cost, commission: commission })
  end

  def json
    JSON.pretty_generate(output)
  end

  def write_to_disk
    bytes_written = @output_file.write(json)
    @output_file.close
    bytes_written
  end
end
