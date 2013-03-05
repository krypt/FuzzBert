require 'fuzzbert'

# To use this Handler, you must pass it as an argument
# to the 'fuzzbert' executable, something like
#
#   fuzzbert --handler MyHandler "FILE_PATTERN"
#
class MyHandler
  def handle(error_data)
    #create an issue in the bug tracker
    puts error_data[:id]
    p error_data[:data]
    puts error_data[:pid]
    puts error_data[:status]
  end
end

fuzz "Some application" do

  deploy do |data|
    #send the generated data to your application here instead
    p data
  end

  data("completely random") { FuzzBert::Generators.random }

  data "Payload" do
    c = FuzzBert::Container.new
    c << FuzzBert::Generators.fixed("\x30\x80")
    c << FuzzBert::Generators.random
    c.generator
  end

end

