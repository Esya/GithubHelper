# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github_helper/version'

Gem::Specification.new do |gem|
  gem.name          = "github_helper"
  gem.version       = GithubHelper::VERSION
  gem.authors       = ["Tristan Foureur"]
  gem.email         = ["tristan.foureur@gmail.com"]
  gem.description   = %q{A small gem to commit, push to remote, and open a pull request, in a single line. It can also handle issue ids and add them to the Pullrequest's description.}
  gem.summary       = %q{A useful tool to commit, push to remote and open a pull request, in a single line.}
  gem.homepage      = "https://github.com/Esya/GithubHelper"

  gem.post_install_message = "GithubHelper is ready!\nJust type ghh in your terminal in a git folder to start using it."

  gem.files         = `git ls-files`.split($/)
  gem.executables   << 'ghh'
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "httparty"
  gem.add_dependency "git"
  gem.add_dependency "json"
  gem.add_dependency "highline"
end
