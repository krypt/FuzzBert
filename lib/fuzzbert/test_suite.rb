
class FuzzBert::TestSuite

  attr_reader :description, :test, :generators

  def initialize(desc)
    @description = desc
    @generators = []
  end

  def deploy(&blk)
    @test = FuzzBert::Test.new(blk)
  end

  def data(desc, &blk)
    @generators << FuzzBert::Generator.new(desc, blk.call)
  end

  def self.create(desc, &blk)
    obj = self.new(desc)
    obj.instance_eval(&blk) if blk
    obj
  end
 
end
