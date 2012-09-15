require 'rspec'
require 'fuzzbert'

describe FuzzBert::Generator do

  describe "new" do
    it "takes a description and a generator" do
      desc = "desc"
      value = "test"
      gen = FuzzBert::Generator.new(desc, FuzzBert::Generators.fixed(value))
      gen.description.should == desc
      gen.to_data.should == value
    end

    it "takes a block that is executed when to_data is called when no explicit generator is given" do
      value = "test"
      desc = "desc"
      gen = FuzzBert::Generator.new(desc) { value }
      gen.description.should == desc
      gen.to_data.should == value
    end
  end

end

