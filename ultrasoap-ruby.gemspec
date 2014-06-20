Gem::Specification.new do |s|
  s.name          = 'ultrasoap'
  s.version       = '0.1.0'
  s.summary       = "Simple Ruby client library for UltraDNS SOAP API"
  s.description   = "Connect to Neustar's UltraDNS SOAP API. FKA ultrasoap-ruby"
  s.authors       = ["Gabriel Sambarino"]
  s.email         = 'gabriel.sambarino@gmail.com'
  s.files         = `git ls-files`.split("\n")
  s.homepage      = 'https://github.com/chrean/ultrasoap-ruby'
  s.license       = "MIT"
  s.require_paths = ["lib"]
  s.required_ruby_version = '~> 2.0'

  s.rubyforge_project = s.name
  s.license = 'MIT'

  s.add_dependency "savon", "~> 2.0"
  s.add_dependency "settingslogic", "~> 2.0"

  s.add_development_dependency "rspec", "~> 2.10"

end
