require 'fuzzbert'

# To use this Handler, you must pass it as an argument
# to the 'fuzzbert' executable, something like
#
#   fuzzbert --handler MyHandler "FILE_PATTERN"
#
class MyHandler
  def handle(id, data, pid, status)
    #create an issue in the bug tracker
    puts id
  end
end

fuzz "OpenSSL command line (asn1parse)" do

  deploy do |data|
    IO.popen("openssl asn1parse -inform DER -noout", "w") do |io|
      io.write(data)
    end
    status = $?
    unless status.exited? && status.success?
      raise RuntimeError.new("bug!")
    end
  end

  data("completely random") { FuzzBert::Generators.random }

  data "Indefinite length sequence" do
    c = FuzzBert::Container.new
    c << FuzzBert::Generators.fixed("\x30\x80")
    c << FuzzBert::Generators.random
    c.generator
  end

end
