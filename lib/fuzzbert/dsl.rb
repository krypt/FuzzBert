module FuzzBert::DSL
  def fuzz(*args, &blk)
    suite = FuzzBert::TestSuite.create(*args, &blk)
    FuzzBert::AutoRun.register(suite)
  end
end

extend FuzzBert::DSL
Module.send(:include, FuzzBert::DSL)
