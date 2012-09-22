require 'fuzzbert'

fuzz "String.to_i" do
  deploy do |data|
    begin
      String.to_i(data)
    rescue StandardError
    end
  end

  data("completely random") { FuzzBert::Generators.random }

  data("1..1000") { FuzzBert::Generators.cycle(1..1000) }

  data "leading zero, fixed length of 100 digits" do
    c = FuzzBert::Container.new
    c << FuzzBert::Generators.fixed("0")
    c << FuzzBert::Generators.random_fixlen(99)
    c.generator
  end

end

