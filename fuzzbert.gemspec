require 'fileutils'

Gem::Specification.new do |s|
  s.name = 'fuzzbert'
  s.version = '0.0.1'
  s.author = 'Martin Bosslet'
  s.email = 'Martin.Bosslet@googlemail.com'
  s.homepage = 'https://github.com/krypt/FuzzBert'
  s.files = Dir.glob('{lib,spec,test}/**/*')
  s.test_files = Dir.glob('test/**/test_*.rb')
  s.require_path = "lib"
end
