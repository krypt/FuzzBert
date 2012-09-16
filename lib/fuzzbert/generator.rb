
class FuzzBert::Generator
  include FuzzBert::Generation

  attr_reader :description

  def initialize(desc, generator=nil, &blk)
    @description = desc
    @generator = generator || blk
    raise RuntimeError.new("No generator given") unless @generator
  end

  def to_data
    @generator.call
  end

end

