require 'fuzzbert'

fuzz "Web App" do
  deploy do |data|
    #send JSON data via HTTP
  end

  data "template" do
    t = FuzzBert::Template.new <<-EOS
      { user: { id: ${id}, name: "${name}" } }
    EOS
    t.set(:id) { FuzzBert::Generators.cycle(1..10000) }
    t.set(:name) { FuzzBert::Generators.random }
    t.generator
  end
end
