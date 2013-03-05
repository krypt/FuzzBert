require 'fuzzbert'

fuzz "Web App" do
  deploy do |data|
    #send JSON data via HTTP here instead
    p data
  end

  data "template" do
    t = FuzzBert::Template.new <<-EOS
      { user: { id: ${id}, name: "${name}", text: "${text}" } }
    EOS
    t.set(:id, FuzzBert::Generators.cycle(1..10000))
    name = FuzzBert::Container.new
    name << FuzzBert::Generators.fixed("fixed")
    name << FuzzBert::Generators.random_fixlen(2)
    t.set(:name, name.generator)
    t.set(:text) { "Fixed text plus two random bytes: #{FuzzBert::Generators.random_fixlen(2).call}" }
    t.generator
  end
end
