require 'fuzzbert'

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
    c << FuzzBert::Generators.fixed("\x31\x80")
    c << FuzzBert::Generators.random
    c << FuzzBert::Generators.fixed("\x00\x00")
    c.generator
  end

end

