
class FuzzBert::Mutator < FuzzBert::Generator

  def initialize(desc, value)
    orig = value.dup
    orig.force_encoding(Encoding::BINARY)
    super(desc) do
      #select a byte
      i = FuzzBert::PRNG.rand(value.size)
      old = orig[i].ord
      #map a random value from 0..254 to 0..255 excluding the current value
      b = FuzzBert::PRNG.rand(255)
      b = b < old ? b : b + 1
      orig.dup.tap { |s| s.setbyte(i, b) }
    end
  end

end

