require_relative "./lib/shlog/version"

Gem::Specification.new do |spec|
  spec.name          = "shlog"
  spec.version       = Shlog::VERSION
  spec.authors       = ["Aziz Light"]
  spec.email         = ["aziz@azizlight.me"]
  spec.description   = %q{A wrapper around lumberjack (https://github.com/bdurand/lumberjack) to make logging on the command line easier.}
  spec.summary       = %q{Command-line logging made easy}
  spec.homepage      = "https://github.com/AzizLight/shlog"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "gli", "2.8.1"
end
