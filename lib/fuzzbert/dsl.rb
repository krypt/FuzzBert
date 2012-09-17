module FuzzBert::DSL
  def fuzz(*args, &blk)
    suite = FuzzBert::TestSuite.create(*args, &blk)
    raise RuntimeError.new "No 'deploy' block was given" unless suite.test
    raise RuntimeError.new "No 'data' blocks were given" unless suite.generators
    FuzzBert::AutoRun.register(suite)
  end
end

extend FuzzBert::DSL
Module.send(:include, FuzzBert::DSL)
