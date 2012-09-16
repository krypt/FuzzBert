require 'fileutils'

Gem::Specification.new do |s|
  s.name = 'fuzzbert'
  s.version = '1.0.0'
  s.author = 'Martin Bosslet'
  s.email = 'Martin.Bosslet@gmail.com'
  s.homepage = 'https://github.com/krypt/FuzzBert'
  s.summary = 'A random testing / fuzzer framework for Ruby.'
  s.files = Dir.glob('{lib}/**/*')
  s.files += ["LICENSE"]
  s.test_files = Dir.glob('spec/**/*.rb')
  s.extra_rdoc_files = [ "README.rdoc" ]
  s.bindir = "bin"
  s.executables = ['fuzzbert']
  s.require_path = "lib"
end
