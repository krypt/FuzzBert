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

  describe "command line" do

    def relative_path(filename)
      File.expand_path(filename, File.dirname(File.expand_path(__FILE__)))
    end

    let (:fuzz_nothing) { relative_path('fuzz/fuzz_nothing.rb') }
    let (:single_test_args) { ['--pool-size', '1', '--limit', '1', '--sleep-delay', '0.05'] }

    it "accepts pool-size, limit and sleep-delay" do 
      args = single_test_args + [fuzz_nothing]
      -> { FuzzBert::AutoRun.autorun_with_args(args) }.should_not raise_error
    end

    it "accepts console" do 
      args = single_test_args + ['--console', fuzz_nothing]
      -> { FuzzBert::AutoRun.autorun_with_args(args) }.should_not raise_error
    end

    it "accepts bug-dir" do
      args = single_test_args + ['--bug-dir', '.', fuzz_nothing]
      -> { FuzzBert::AutoRun.autorun_with_args(args) }.should_not raise_error
    end

    it "accepts a custom handler" do
      args = single_test_args + ['--handler', 'FuzzBert::Spec::CustomHandler', relative_path('fuzz/fuzz_custom_handler.rb')]
      -> { FuzzBert::AutoRun.autorun_with_args(args) }.should_not raise_error
      FuzzBert::Spec::CustomHandler.called.should be_true
    end

    it "accepts multiple single files" do
      args = [
        '--pool-size', '1',
        '--limit', '2',
        '--sleep-delay', '0.05',
        '--handler', 'FuzzBert::Spec::CustomHandler',
        fuzz_nothing, relative_path('fuzz/fuzz_custom_handler.rb')
      ]
      -> { FuzzBert::AutoRun.autorun_with_args(args) }.should_not raise_error
      FuzzBert::Spec::CustomHandler.called.should be_true
    end

    it "accepts a pattern" do
      args = [
        '--pool-size', '1',
        '--limit', '2',
        '--sleep-delay', '0.05',
        '--handler', 'FuzzBert::Spec::CustomHandler',
        relative_path('fuzz/**/fuzz_*.rb')
      ]
      -> { FuzzBert::AutoRun.autorun_with_args(args) }.should_not raise_error
      FuzzBert::Spec::CustomHandler.called.should be_true
    end
  end

end

