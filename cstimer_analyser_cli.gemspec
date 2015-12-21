# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cstimer_analyser_cli/version'

Gem::Specification.new do |spec|
  spec.name          = "cstimer_analyser_cli"
  spec.version       = CstimerAnalyserCli::VERSION
  spec.authors       = ["Siddharth Kannan"]
  spec.email         = ["kannan.siddharth12@gmail.com"]
	spec.executables << 'cstimer-analyse'
  spec.summary       = %q{Analyse your solving times, generated using cstimer}
  spec.description   = %q{Gain insights into how you have improved over time. Has graphs, and other fancy stuff.}
  spec.homepage      = "http://icyflame.me/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

	spec.add_dependency "statsample", "~> 0"
	spec.add_dependency "optparse", "> 0.5.1"
	spec.add_dependency "gnuplot", "~> 2.6.2"
	#spec.add_dependency "highline"
	#spec.add_dependency "cli-console"
end
