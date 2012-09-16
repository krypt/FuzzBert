require 'optparse'

module FuzzBert::AutoRun

  TEST_CASES = []

  module_function

  def register(suite)
    TEST_CASES << suite
  end

  def autorun
    options, files = process_args(ARGV)
    load_files(files)
    run(options)
  end

  def run(options=nil)
    executor = options ? FuzzBert::Executor.new(TEST_CASES, options) : FuzzBert::Executor.new(TEST_CASES)
    executor.run
  end

  private; module_function

  def load_files(files)
    files.each do |pattern|
      Dir.glob(pattern).each { |f| load File.expand_path(f) }
    end
  end

  def process_args(args = [])
    options = {}
    orig_args = args.dup

    OptionParser.new do |opts|
      opts.banner  = 'FuzzBert options:'
      opts.version = FuzzBert::VERSION

      opts.on '-h', '--help', 'Display this help.' do
        puts opts
        exit
      end

      opts.on '--pool-size SIZE', Integer, "Sets the number of concurrently running processes to SIZE" do |n|
        options[:pool_size] = n.to_i
      end

      opts.on '--limit LIMIT', Integer, "Instead of running permanently, fuzzing will be stopped after running LIMIT of instances" do |n|
        p n
        options[:limit] = n.to_i
      end

      opts.on '--console', "Output the failing cases including data on the console instead of saving them in a file" do
        options[:handler] = FuzzBert::Handler::Console.new
      end

      opts.parse! args
    end

    [options, args]
  end

end

