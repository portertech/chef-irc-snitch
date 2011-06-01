# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chef-irc-snitch/version"

Gem::Specification.new do |s|
  s.name        = "chef-irc-snitch"
  s.version     = Chef::IRC::Snitch::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sean Porter"]
  s.email       = ["portertech@gmail.com"]
  s.homepage    = "https://github.com/portertech/chef-irc-snitch"
  s.summary     = %q{An exception handler for OpsCode Chef runs (GitHub Gists & IRC)}
  s.description = %q{An exception handler for OpsCode Chef runs (GitHub Gists & IRC)}
  s.has_rdoc    = false
  s.license     = "MIT"

  s.rubyforge_project = "chef-irc-snitch"

  s.add_dependency('chef')
  s.add_dependency('shout-bot-portertech')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
