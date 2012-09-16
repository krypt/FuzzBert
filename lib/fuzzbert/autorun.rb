
module FuzzBert::AutoRun

  TEST_CASES = []

  module_function

  def register(suite)
    TEST_CASES << suite
  end

  def run
    FuzzBert::Executor.new(TEST_CASES).run
  end

end

