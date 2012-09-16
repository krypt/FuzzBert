
class FuzzBert::Test

  def initialize(runner)
    @runner = runner
  end

  def run(data)
    @runner.call data
  end

end

