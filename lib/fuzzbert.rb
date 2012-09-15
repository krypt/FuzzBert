=begin

= Info

FuzzBert - Random Testing / Fuzzing in Ruby

Copyright (C) 2012
Martin Bosslet <martin.bosslet@googlemail.com>
All rights reserved.

= License

See the file 'LICENSE' for further details.

=end

module FuzzBert

  PRNG = Random.new

end

require_relative 'fuzzbert/generators'
require_relative 'fuzzbert/generator'
require_relative 'fuzzbert/template'
require_relative 'fuzzbert/container'
require_relative 'fuzzbert/test'
require_relative 'fuzzbert/error_handler'
require_relative 'fuzzbert/executor'
require_relative 'fuzzbert/description'
require_relative 'fuzzbert/dsl'



