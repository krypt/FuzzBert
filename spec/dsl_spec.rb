require 'rspec'
require 'fuzzbert'

describe FuzzBert::TestSuite do
  describe "fuzz" do
    context "with one generator" do
      let(:suite) do
        FuzzBert::TestSuite.create "test" do
          deploy { |data| data }

          data("1") { FuzzBert::Generators.random }
        end
      end

      it "returns an instance of TestSuite" do
        suite.should be_an_instance_of(FuzzBert::TestSuite)
        suite.description.should == "test"
      end

      it "defines a test that executes the block in deploy" do
        suite.test.should_not be_nil
        suite.test.should be_an_instance_of(FuzzBert::Test)
        ["a", 10, true, Object.new].each { |o| suite.test.run(o).should == o }
      end

      it "defines one generator" do
        suite.generators.size.should == 1
        gen = suite.generators.first
        gen.should be_an_instance_of(FuzzBert::Generator)
        gen.description.should == "1"
        gen.to_data.should be_an_instance_of(String)
      end

    end

    context "with two generators" do
      let(:suite) do
        FuzzBert::TestSuite.create "test" do
          deploy { |data| data }

          data("1") { FuzzBert::Generators.fixed(1) }
          data("2") { FuzzBert::Generators.fixed(2) }
        end
      end

      it "defines two generators" do
        suite.generators.size.should == 2
        gen = suite.generators.first
        gen.should be_an_instance_of(FuzzBert::Generator)
        gen.description.should == "1"
        gen.to_data.should == 1

        gen = suite.generators[1]
        gen.should be_an_instance_of(FuzzBert::Generator)
        gen.description.should == "2"
        gen.to_data.should == 2
      end

    end

    context "with complex data" do
      let(:suite) do
        FuzzBert::TestSuite.create "test" do
          deploy { |data| data }

          data "1" do
            c = FuzzBert::Container.new
            c << FuzzBert::Generators.fixed("1")
            c << FuzzBert::Generators.fixed("2")
            c << FuzzBert::Generators.fixed("3")
            c.generator
          end

        end
      end

      it "applies the container generators in sequence" do
        suite.generators.size.should == 1
        gen = suite.generators.first
        gen.should be_an_instance_of(FuzzBert::Generator)
        gen.description.should == "1"
        gen.to_data.should == "123"
      end
    end
  end

  it "raises an error when no block is given" do
    -> { FuzzBert::TestSuite.create "test" }.should raise_error
  end

  it "raises an error when the deploy block is missing" do
    lambda do
      FuzzBert::TestSuite.create "test" do
          data("1") { FuzzBert::Generators.random }
      end.should raise_error
    end
  end

  it "raises an error when the data blocks are missing" do
    lambda do
      FuzzBert::TestSuite.create "test" do
          deploy { |data| data }
      end.should raise_error
    end
  end

  describe "deploy" do
    it "raises an error when no block is given" do
      lambda do
        FuzzBert::TestSuite.create "test" do
          deploy

          data("1") { FuzzBert::Generators.random }
        end
      end.should raise_error
    end
  end

  describe "data" do
    it "raises an error when no block is given" do
      lambda do
        FuzzBert::TestSuite.create "test" do
          deploy { |data| data }
          data("1")
        end
      end.should raise_error
    end
  end

end

