# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mysql_health/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Erik Osterman"]
  gem.email         = ["e@osterman.com"]
  gem.summary       = %q{A service for monitoring MySQL and exposing its health through an HTTP interface.}
  gem.description   = %q{A service for monitoring MySQL and exposing its health through an HTTP interface for use with TCP load balancers (like haproxy) that support out-of-band health checks using HTTP.}
  gem.homepage      = ""
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mysql_health"
  gem.license       = 'GPLv3'
  gem.require_paths = ["lib"]
  gem.version       = MysqlHealth::VERSION
  gem.add_runtime_dependency('rufus-scheduler',  '>= 2.0.17')
  gem.add_runtime_dependency('eventmachine', '>= 1.0.0.beta.4')
  gem.add_runtime_dependency('eventmachine_httpserver', '>= 0.2.1')
  gem.add_runtime_dependency('json', '>= 1.5.3')
  gem.add_runtime_dependency('dbi', '>= 0.4.5')
  gem.add_runtime_dependency('mysql', '>= 2.8.1')
end
