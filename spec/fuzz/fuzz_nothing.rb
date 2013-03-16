require 'fuzzbert'

fuzz "nothing" do
  deploy { |_| }
  data("some") { -> {"a"} }
end
