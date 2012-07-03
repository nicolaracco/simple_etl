# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_etl/version"

Gem::Specification.new do |s|
  s.name        = "simple_etl"
  s.version     = SimpleEtl::VERSION
  s.authors     = ["Nicola Racco"]
  s.email       = ["nicola@nicolaracco.com"]
  s.homepage    = ""
  s.summary     = %q{An easy-to-use toolkit to help you with ETL (Extract Transform Load) operations}
  s.description = %q{An easy-to-use toolkit to help you with ETL (Extract Transform Load) operations. Simple ETL 'would be' (:D) framework-agnostic and easy to use.}

  s.rubyforge_project = "simple_etl"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rspec'
end
