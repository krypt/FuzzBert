require 'rspec'
require 'fuzzbert'

describe FuzzBert::Mutator do

  describe "new" do
    it "takes a (valid) base value" do
      value = "test"
      mut = FuzzBert::Mutator.new(value)
    end
  end

  it "includes Generation" do
    mut = FuzzBert::Mutator.new("value")
    mut.generator.should_not be_nil
  end

  describe "#to_data" do
    it "mutates the base value in exactly one position" do
      value = "FuzzBert"
      mut = FuzzBert::Mutator.new(value)
      mutated = mut.to_data
      diff = 0
      value.each_byte.each_with_index do |b, i|
        diff += 1 unless b == mutated[i].ord
      end
      diff.should == 1
    end
  end

end

