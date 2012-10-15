# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fossilize/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Anthony Gibbins"]
  gem.email         = ["xiy3x0@gmail.com"]
  gem.description   = %q{A ruby extension to the Fossil delta compression algorithm written
                      by D. Richard Hipp for the Fossil SCM project.}
  gem.summary       = %q{Delta compression for Ruby using the Fossil delta
                      compression algorithm.}
  gem.homepage      = "http://github.com/xiy/fossilize"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fossilize"
  gem.require_paths = ["lib"]
  gem.version       = Fossilize::VERSION

  gem.extensions = ['ext/fossilize/extconf.rb']

  gem.add_runtime_dependency('ffi')
  gem.add_runtime_dependency('digest-crc')

  gem.add_development_dependency('rspec', '2.8.0')
  gem.add_development_dependency('tomdoc')
end
