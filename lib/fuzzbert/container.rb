
class FuzzBert::Container
  include FuzzBert::Generation

  def initialize(generators=[])
    @generators = generators
  end

  def <<(generator)
    @generators << generator
  end

  def to_data
    "".tap do |buf|
      @generators.each { |gen| buf << gen.call }
    end
  end

end


