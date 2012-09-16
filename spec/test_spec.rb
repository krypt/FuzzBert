require 'rspec'
require 'fuzzbert'

describe FuzzBert::Test do

  describe "new" do
    it "takes a mandatory proc argument" do
      -> { FuzzBert::Test.new }.should raise_error
      FuzzBert::Test.new( lambda { |data| data }).should be_an_instance_of(FuzzBert::Test)
    end
  end

  describe "#run" do
    it "executes the block passed on creation with the data passed to it" do
      value = "test"
      t = FuzzBert::Test.new( lambda { |data| data })
      t.run(value).should == value
    end
  end
end
