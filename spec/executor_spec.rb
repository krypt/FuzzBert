require 'rspec'
require 'fuzzbert'

describe FuzzBert::Executor do

  describe "::new" do
    let(:test) do
      #NOTE: Do we need the test variable here?
      test = FuzzBert::Test.new(lambda { |data| data })
      FuzzBert::TestSuite.create("suite") do
        deploy { |data| data }
        data("1") { FuzzBert::Generators.random }
      end
    end

    it "takes a mandatory (array of) TestSuite as first argument" do
      -> { FuzzBert::Executor.new }.should raise_error ArgumentError
      FuzzBert::Executor.new(test).should be_an_instance_of(FuzzBert::Executor)
      FuzzBert::Executor.new([test]).should be_an_instance_of(FuzzBert::Executor)
    end

    it "raises an ArgumentError if the TestSuite argument is nil" do
      -> { FuzzBert::Executor.new(nil) }.should raise_error ArgumentError
    end

    it "raises an ArgumentError if the TestSuite argument is empty" do
      -> { FuzzBert::Executor.new([]) }.should raise_error ArgumentError
    end

    it "allows a pool_size argument" do
      size = 1
      executor = FuzzBert::Executor.new(test, pool_size: size)
      executor.pool_size.should == size
    end

    it "allows a limit argument" do
      limit = 42
      executor = FuzzBert::Executor.new(test, limit: limit)
      executor.limit.should == limit
    end

    it "allows a handler argument" do
      handler = FuzzBert::Handler::Console.new
      executor = FuzzBert::Executor.new(test, handler: handler)
      executor.handler.should == handler
    end

    it "allows a sleep_delay argument" do
      delay = 0.1
      executor = FuzzBert::Executor.new(test, sleep_delay: delay)
      executor.sleep_delay.should == delay
    end

    it "defaults pool_size to 4" do
      FuzzBert::Executor.new(test).pool_size.should == 4
    end

    it "defaults limit to -1" do
      FuzzBert::Executor.new(test).limit.should == -1
    end

    it "defaults handler to a FileOutputHandler" do
      FuzzBert::Executor.new(test).handler.should be_an_instance_of(FuzzBert::Handler::FileOutput)
    end

    it "defaults sleep_delay to 1" do
      FuzzBert::Executor.new(test).sleep_delay.should == 1
    end
  end

  describe "#run" do
    subject { FuzzBert::Executor.new(suite, pool_size: 1, limit: 1, handler: handler, sleep_delay: 0.05).run }

    class TestHandler
      def initialize(&blk)
        @handler = blk
      end

      def handle(error_data)
        @handler.call(error_data)
      end
    end

    context "doesn't complain when test succeeds" do
      let (:suite) do
        FuzzBert::TestSuite.create("suite") do
          deploy { |data| data } 
          data("1") { -> { "a" } }
        end
      end
      let (:handler) { TestHandler.new { |_| raise RuntimeError.new } }
      it { -> { subject }.should_not raise_error }
    end

    context "reports an unrescued exception" do
      called = false
      let (:suite) do
        FuzzBert::TestSuite.create("suite") do
          deploy { |_| raise "boo!" }
          data("1") { -> { "a" } }
        end
      end
      let (:handler) { TestHandler.new { |_| called = true } }
      it { -> { subject }.should_not raise_error; called.should be_true }
    end

    context "allows rescued exceptions" do
      let (:suite) do
        FuzzBert::TestSuite.create("suite") do
          deploy { |_| begin; raise "boo!"; rescue RuntimeError; end }
          data("1") { -> { "a" } }
        end
      end
      let (:handler) { TestHandler.new { |_| raise RuntimeError.new } }
      it { -> { subject }.should_not raise_error }
    end

    context "can handle SEGV" do
      called = false
      let (:suite) do
        FuzzBert::TestSuite.create("suite") do
          deploy { |_| Process.kill(:SEGV, Process.pid) }
          data("1") { -> { "a" } }
        end
      end
      let (:handler) { TestHandler.new { |_| called = true } }
      let (:generator) { FuzzBert::Generator.new("test") { "a" } }
      it { -> { subject }.should_not raise_error; called.should be_true }
    end if false #don't want to SEGV every time
  end

end
