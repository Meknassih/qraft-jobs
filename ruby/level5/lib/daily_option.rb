# Additional feature that is recurring daily
class DailyOption
  attr_reader :id, :rental_id
  attr_accessor :type

  def initialize(id:, rental_id:, type:)
    # Class variables are not recommended
    @types = {
      gps: { price: 500, beneficiary: 'owner' },
      baby_seat: { price: 200, beneficiary: 'owner' },
      additional_insurance: { price: 1000, beneficiary: 'drivy' }
    }
    @type = type
    raise "Invalid option type: #{type}" unless @types.key?(type.to_sym)

    @rental_id = rental_id
    @id = id
  end

  def cost(days)
    @types[type.to_sym][:price] * days
  end

  def beneficiary
    @types[type.to_sym][:beneficiary]
  end
end
