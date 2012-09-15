module FuzzBert::DSL
  def fuzz(*args, &blk)
    desc = FuzzBert::Description.fuzz(*args, blk)
    p desc
  end
end

extend FuzzBert::DSL
Module.send(:include, FuzzBert::DSL)
