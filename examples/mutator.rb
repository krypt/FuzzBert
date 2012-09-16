require 'fuzzbert'

fuzz "Web App" do
  deploy do |data|
    #send JSON data via HTTP
  end

  data "mutated data" do
    #in practice, choose a moderately sized value that is generally accepted by the target
    m = FuzzBert::Mutator.new '{ user: { id: 42, name: "FuzzBert" }'
    m.generator
  end
end
