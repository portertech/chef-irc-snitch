Gem::Specification.new do |s|
  s.name        = "chef-irc-snitch"
  s.version     = "0.0.8"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sean Porter", "Aaron Daniel"]
  s.email       = ["portertech@gmail.com", "amdtech@me.com"]
  s.homepage    = "https://github.com/ninjawarriors/chef-irc-snitch"
  s.summary     = %q{An exception handler for OpsCode Chef runs (GitHub Gists & IRC)}
  s.description = %q{An exception handler for OpsCode Chef runs (GitHub Gists & IRC)}
  s.has_rdoc    = false
  s.license     = "MIT"

  s.rubyforge_project = "chef-irc-snitch"

  s.add_dependency('chef')
  s.add_dependency('carrier-pigeon')

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
