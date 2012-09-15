require 'rspec'
require 'fuzzbert'

describe FuzzBert::Description do
  describe "fuzz" do
    context "one generator" do
      let(:desc) do
        FuzzBert::Description.fuzz "test" do
          deploy do |data|
            data
          end

          data "1" do
            FuzzBert::Generators.random
          end
        end
      end

      it "returns an instance of Description" do
        desc.should be_an_instance_of(FuzzBert::Description)
        desc.description.should == "test"
      end

      it "defines a test that executes the block in deploy" do
        desc.test.should_not be_nil
        desc.test.should be_an_instance_of(FuzzBert::Test)
        ["a", 10, true, Object.new].each { |o| desc.test.run(o).should == o }
      end

      it "defines one generator" do
        desc.generators.size.should == 1
        gen = desc.generators.first
        gen.should be_an_instance_of(FuzzBert::Generator)
        gen.description.should == "1"
        gen.to_data.should be_an_instance_of(String)
      end

    end

    context "two generators" do
      let(:desc) do
        FuzzBert::Description.fuzz "test" do
          deploy do |data|
            data
          end

          data "1" do
            FuzzBert::Generators.fixed(1)
          end

          data "2" do
            FuzzBert::Generators.fixed(2)
          end
        end
      end

      it "defines two generators" do
        desc.generators.size.should == 2
        gen = desc.generators.first
        gen.should be_an_instance_of(FuzzBert::Generator)
        gen.description.should == "1"
        gen.to_data.should == 1

        gen = desc.generators[1]
        gen.should be_an_instance_of(FuzzBert::Generator)
        gen.description.should == "2"
        gen.to_data.should == 2
      end

    end
  end
end

