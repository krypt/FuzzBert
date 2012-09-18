require 'fuzzbert'

fuzz "nothing" do
  deploy { |data| }
  data("some") { -> {"a"} }
end
