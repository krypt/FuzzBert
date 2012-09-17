
class FuzzBert::TestSuite

  attr_reader :description, :test, :generators

  def initialize(desc)
    @description = desc
    @generators = []
  end

  def deploy(&blk)
    raise RuntimeError.new "No block was given" unless blk
    @test = FuzzBert::Test.new(blk)
  end

  def data(desc, &blk)
    raise RuntimeError.new "No block was given" unless blk
    @generators << FuzzBert::Generator.new(desc, blk.call)
  end

  def self.create(desc, &blk)
    raise RuntimeError.new "No block was given" unless blk
    obj = self.new(desc)
    obj.instance_eval(&blk)
    obj
  end
 
end
