source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '3.7.5' 
end

if rspecpuppetversion = ENV['RSPEC_PUPPET_VERSION']
  gem 'rspec-puppet', rspecpuppetversion, :require => false
else
  gem 'rspec-puppet', '2.5.0' 
end

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
  gem 'fast_gettext', '~> 1.0.0'
  gem 'gettext-setup', '<= 0.13'
  gem 'metadata-json-lint', '<= 0.0.11'
  gem 'rspec', '~> 2.0'
  gem 'rake', '~> 10.4.2'
  gem 'puppet-lint', '~> 1.1.0'
  gem 'puppet-syntax', '~> 2.0.0'
  gem 'facter', '~> 2.4.4'
  gem 'puppetlabs_spec_helper', '~> 1.0.0'
  gem 'json', '~> 1.8.3'
  gem 'json_pure', '~> 1.8.3'
end

# json > v2.0 requires ruby>2.0
if RUBY_VERSION >= '1.9' and RUBY_VERSION < '2.0'
  gem 'fast_gettext', '~> 1.1.0'
  gem 'metadata-json-lint', '~> 1.1.0'
  gem 'rspec', '~> 2.0'
  gem 'rake', '~> 10.4.2'
  gem 'puppet-lint', '~> 1.1.0'
  gem 'puppet-syntax', '~> 2.0.0'
  gem 'facter', '~> 2.4.4'
  gem 'puppetlabs_spec_helper', '~> 1.0.0'
  gem 'json', '~> 1.8.3'
  gem 'json_pure', '~> 1.8.3'
end

if RUBY_VERSION >= '2.0' and RUBY_VERSION < '2.1'
  gem 'fast_gettext', '~> 1.1.0'
  gem 'metadata-json-lint'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
  gem 'facter'
end

if RUBY_VERSION > '2.1'
  gem 'metadata-json-lint'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
  gem 'facter'
end

gem 'beaker'
gem 'beaker-puppet'
gem 'beaker-puppet_install_helper'
gem 'beaker-module_install_helper'
gem 'beaker-testmode_switcher'
gem 'beaker-rspec'
gem 'beaker-docker'
gem 'serverspec'