require 'rspec'
require 'fuzzbert'

describe FuzzBert::AutoRun do

  let(:handler) do
    c = Class.new
    def c.handle(id, data, pid, status)
      raise RuntimeError.new
    end
    c
  end

  value = "test"
  called = false

  fuzz "autorun" do

    deploy do |data|
      data.should == value
    end

    data "1" do
      called = true
      -> { value }
    end

  end

  it "has added a TestSuite to AutoRun" do
    suite = FuzzBert::AutoRun::TEST_CASES
    suite.size.should == 1
    FuzzBert::Executor.new(suite, pool_size: 1, limit: 1, handler: handler).run
    called.should == true
  end

end


