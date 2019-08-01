# frozen_string_literal: true

require_relative 'lib/baberu/version'

Gem::Specification.new do |spec|
  spec.name          = 'baberu'
  spec.version       = Baberu::VERSION
  spec.authors       = ['vzvu3k6k']
  spec.email         = ['vzvu3k6k@gmail.com']

  spec.summary       = 'Babel for Ruby'
  spec.description   = 'Compiles Ruby code for older Ruby implementations'
  spec.homepage      = 'https://github.com/vzvu3k6k/baberu'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/vzvu3k6k/baberu'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1.a'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
