# frozen_string_literal: true

require_relative 'lib/tw/version'

Gem::Specification.new do |spec|
  spec.name          = 'tw'
  spec.version       = Tw::VERSION
  spec.authors       = ['Kyle']
  spec.email         = ['bialogs@gmail.com']

  spec.summary       = 'tw - Twitch Waltuh'
  spec.homepage      = 'http://example.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'eventmachine'
  spec.add_dependency 'faye-websocket'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rubocop'
end
