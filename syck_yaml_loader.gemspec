
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "version"

Gem::Specification.new do |spec|
  spec.name          = "syck_yaml_loader"
  spec.version       = SyckYamlLoader::VERSION
  spec.authors       = ["Hiroshi SHIBATA", "Aaron Patterson", "Mat Brown", "Autodesk.com"]
  spec.email         = ["git@autodesk.com"] # TODO

  spec.summary       = %q{A gemified version of Syck from Ruby's stdlib; trimmed to oly what's required to perform #load}
  spec.description = "A gemified version of Syck from Ruby's stdlib.  Syck has been removed from\nRuby's stdlib, and this gem is meant to bridge the gap for people that haven't\nupdated their YAML yet."

  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  # spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://gems.autodesk.com" # TODO: link to Vela repo once created

    # spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "byebug"
end