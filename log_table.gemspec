# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_table/version'

Gem::Specification.new do |spec|
  spec.name          = 'log_table'
  spec.version       = LogTable::VERSION
  spec.authors       = ['Daisuke Shimamoto']
  spec.email         = ['diskshima@gmail.com']

  spec.summary       = %q{Creates a migration for a log table and triggers}
  spec.description   = %q{log_table creates a log table for the given Active Record model and triggers to write into it.}
  spec.homepage      = 'https://github.com/diskshima/log_table'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hairtrigger', '~> 0.2.17'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.8'
  spec.add_development_dependency 'm', '~> 1.4'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
