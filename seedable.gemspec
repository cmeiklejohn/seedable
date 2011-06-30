# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "seedable/version"

Gem::Specification.new do |s|
  s.name        = "seedable"
  s.version     = Seedable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Meiklejohn"]
  s.email       = ["christopher.meiklejohn@gmail.com"]
  s.homepage    = "http://github.com/cmeiklejohn/seedable"
  s.summary     = %q{Allows for quick serialization/deserialization of objects for moving between environments.}
  s.description = %q{Allows for quick serialization/deserialization of objects for moving between environments.}

  s.rubyforge_project = "seedable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rails', '> 3.0.0')

  s.add_development_dependency('bundler', '~> 1.0.0')
  s.add_development_dependency('rspec') 
  s.add_development_dependency('rspec-rails') 
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('factory_girl')
  s.add_development_dependency('factory_girl_rails')
  s.add_development_dependency('mocha')
  s.add_development_dependency('appraisal', '~> 0.3.5')
  s.add_development_dependency('timecop')
  s.add_development_dependency('horo') 
  s.add_development_dependency('simplecov') 
end
