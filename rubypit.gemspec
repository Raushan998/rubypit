# frozen_string_literal: true

require_relative "lib/rubypit/version"

Gem::Specification.new do |spec|
  spec.name = "rubypit"
  spec.version = Rubypit::VERSION
  spec.authors = ["raushan_raman"]
  spec.email = ["raushan.raman23011999@gmail.com"]

  spec.summary = "ruby_pit!"
  spec.description = "Framework in Ruby"
  spec.homepage = "https://rubygems.org/gems/rubypit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Raushan998/rubypit"
  spec.add_dependency 'sequel', '~> 5.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = ['rubypit']
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
