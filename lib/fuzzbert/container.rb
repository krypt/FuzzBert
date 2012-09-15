
class FuzzBert::Container

  def initialize(generators=[])
    @generators = generators
  end

  def <<(generator)
    @generator << generator
  end

  def to_data
    "".tap do |buf|
      @generators.each { |gen| buf << gen.to_data }
    end
  end

end


