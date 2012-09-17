require 'fileutils'

Gem::Specification.new do |s|
  s.name = 'fuzzbert'
  s.version = '1.0.1'
  s.author = 'Martin Bosslet'
  s.email = 'Martin.Bosslet@gmail.com'
  s.homepage = 'https://github.com/krypt/FuzzBert'
  s.description = 'A random testing / fuzzer framework for Ruby.'
  s.summary = 'Fuzz your applications and libraries with minimal effort.'
  s.files = Dir.glob('{lib}/**/*')
  s.files += ['LICENSE']
  s.test_files = Dir.glob('spec/**/*.rb')
  s.extra_rdoc_files = [ "README.md" ]
  s.bindir = 'bin'
  s.executables = ['fuzzbert']
  s.require_path = 'lib'
  s.license = 'MIT'
end
