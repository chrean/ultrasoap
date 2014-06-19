Gem::Specification.new do |s|
  s.name          = 'ultrasoap-ruby'
  s.version       = '0.0.3'
  s.summary       = "Simple Ruby client library for UltraDNS SOAP API"
  s.authors       = ["Gabriel Sambarino"]
  s.email         = 'gabriel.sambarino@gmail.com'
  s.files         = `git ls-files`.split($/)
  s.homepage      = 'https://github.com/chrean/ultrasoap-ruby'
  s.license       = "mit"
  s.require_paths = ["lib"]
  s.required_ruby_version = '~> 2.0'
end
