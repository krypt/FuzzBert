require 'base64'

module FuzzBert::Generators

  module_function
    
  def random(limit=1024)
    -> { random_bytes(limit) { |data| data } }
  end

  def random_b64(limit=1024)
    -> { random_bytes(b64_len(limit)) { |data| Base64.encode64(data) } }
  end

  def random_hex(limit=1024)
    -> { random_bytes(hex_len(limit)) { |data| data.unpack("H*")[0] } }
  end

  def random_fixlen(len)
    -> { random_bytes_fixlen(len) { |data| data } }
  end

  def random_b64_fixlen(len)
    -> { random_bytes_fixlen(b64_len(len)) { |data| Base64.encode(data) } }
  end

  def random_hex_fixlen(len)
    -> { random_bytes_fixlen(hex_len(len)) { |data| data.unpack("H*")[0] } }
  end

  def cycle(range)
    ary = range.to_a
    i = 0
    lambda do
      ret = ary[i]
      i = (i + 1) % ary.size
      ret
    end
  end
  
  def fixed(data)
    -> { data }
  end

  def sample(ary)
    -> { ary.sample }
  end

  private; module_function

    def hex_len(len)
      len / 2
    end

    def b64_len(len)
      len * 3 / 4
    end

    def random_bytes(limit)
      len = FuzzBert::PRNG.rand(1..limit)
      yield FuzzBert::PRNG.bytes(len)
    end

    def random_bytes_fixlen(len)
      yield FuzzBert::PRNG.bytes(len)
    end

end
