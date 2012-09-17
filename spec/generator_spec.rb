require 'rspec'
require 'fuzzbert'

describe FuzzBert::Generator do

  describe "::new" do
    it "takes a description and a generator" do
      desc = "desc"
      value = "test"
      gen = FuzzBert::Generator.new(desc, FuzzBert::Generators.fixed(value))
      gen.description.should == desc
      gen.to_data.should == value
    end
  end

  describe "#generator" do
    it "implements Generation" do
      gen = FuzzBert::Generator.new("test") { "test" }
      gen.generator.should_not be_nil
    end
  end

  describe "#to_data" do
    it "returns the value returned by its generator" do
      value = "test"
      desc = "desc"
      gen = FuzzBert::Generator.new(desc) { value }
      gen.description.should == desc
      gen.to_data.should == value
    end
  end
end

