source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '3.7.5' 
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
  gem 'rspec-puppet', '~> 2.5.0' 
end

if RUBY_VERSION >= '2.0' and RUBY_VERSION < '2.1'
  gem 'fast_gettext', '~> 1.1.0'
  gem 'metadata-json-lint'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper', '~> 2.15.0'
  gem 'puppet-lint'
  gem 'facter'
  gem 'rspec-puppet', '~> 2.5.0' 
end

if RUBY_VERSION >= '2.1' and RUBY_VERSION < '2.5'
  gem 'metadata-json-lint'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper', '~> 2.15.0'
  gem 'puppet-lint'
  gem 'facter'
  gem 'rspec-puppet', '~> 2.5.0' 
end

if RUBY_VERSION >= '2.5' and RUBY_VERSION < '2.8'
  gem 'metadata-json-lint'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
  gem 'facter'
  gem 'rspec-puppet', '~> 2.8.0'
end

gem 'rspec-puppet-augeas'
