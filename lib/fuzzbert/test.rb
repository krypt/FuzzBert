
class FuzzBert::Test

  attr_reader :description

  def initialize(desc=nil, &runner)
    raise RuntimeError.new unless block_given?
    @description = desc
    @runner = runner
  end

  def run(data)
    @runner.call data
  end

end

