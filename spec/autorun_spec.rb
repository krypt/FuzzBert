require 'rspec'
require 'fuzzbert'


describe FuzzBert::AutoRun do

  after(:each) do
    #clear any TestSuites that were created
    FuzzBert::AutoRun::TEST_CASES.clear
  end

  let(:handler) do
    c = Class.new
    def c.handle(error_data)
      raise RuntimeError.new
    end
    c
  end

  
  context "with a valid test" do
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
      FuzzBert::AutoRun::TEST_CASES.size.should == 1
      FuzzBert::AutoRun.run(pool_size: 1, limit: 1, handler: handler, sleep_delay: 0.05)
      called.should == true
    end
  end

  context "with no test" do
    it "raises an error when executed" do
      FuzzBert::AutoRun::TEST_CASES.should be_empty
      -> { FuzzBert::AutoRun.run }.should raise_error
    end
  end

end

