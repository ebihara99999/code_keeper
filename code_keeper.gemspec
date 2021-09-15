# frozen_string_literal: true

require_relative "lib/code_keeper/version"

Gem::Specification.new do |spec|
  spec.name          = "code_keeper"
  spec.version       = CodeKeeper::VERSION
  spec.authors       = ["Yusuke Ebihara"]
  spec.email         = ["dev.biibiebi@gmail.com"]

  spec.summary       = "Measures metrics about complexity and size."
  spec.description   = "The CodeKeeper measures metrics especially about complexity and size of Ruby files, aiming to be a Ruby version of gmetrics."
  spec.homepage      = "https://github.com/ebihara99999/code_keeper"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ebihara99999/code_keeper/"
  spec.metadata["changelog_uri"] = "https://github.com/ebihara99999/code_keeper/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "parallel", '~> 1.20.1'
  spec.add_dependency "rubocop", '~> 1.13.0'
  spec.add_dependency "rubocop-ast", '~> 1.4.1'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
