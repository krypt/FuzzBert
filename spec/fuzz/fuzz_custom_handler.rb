require 'fuzzbert'

module FuzzBert::Spec
  class CustomHandler
    @@called = false
    
    def self.called
      @@called
    end

    def handle(error_data)
      @@called = true
    end
  end
end

fuzz "failing" do
  deploy { |data| raise "boo!" }
  data("some") { -> {"a"} }
end
