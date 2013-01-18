=begin

= Info

FuzzBert - Random Testing / Fuzzing in Ruby

Copyright (C) 2012-2013
Martin Bosslet <martin.bosslet@gmail.com>
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=end

module FuzzBert

  PRNG = Random.new

end

require_relative 'fuzzbert/version'
require_relative 'fuzzbert/generation'
require_relative 'fuzzbert/generators'
require_relative 'fuzzbert/generator'
require_relative 'fuzzbert/mutator'
require_relative 'fuzzbert/template'
require_relative 'fuzzbert/container'
require_relative 'fuzzbert/test'
require_relative 'fuzzbert/error_handler'
require_relative 'fuzzbert/test_suite'
require_relative 'fuzzbert/executor'
require_relative 'fuzzbert/autorun'
require_relative 'fuzzbert/dsl'

