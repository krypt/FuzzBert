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
    c << FuzzBert::Generators.fixed("\x30\x80")
    c << FuzzBert::Generators.random
    c.generator
  end

end

