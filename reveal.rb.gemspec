lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reveal/version'

Gem::Specification.new do |gem|
  gem.name          = "reveal.rb"
  gem.version       = Reveal::VERSION
  gem.authors       = ["Guilherme Garnier"]
  gem.email         = ["guilherme.garnier@gmail.com"]
  gem.summary       = "Presentation generator using reveal.js"
  gem.description   = "Generates presentations using reveal.js"
  gem.homepage      = "https://github.com/ggarnier/reveal.rb"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
