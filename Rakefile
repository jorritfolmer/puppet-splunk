require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec/core/rake_task'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

desc "Validate manifests, templates, and ruby files"
task :test => [
  :syntax,
  :validate_output,
  :validate,
  :spec_output,
  :spec,
  :lint_output,
  :lint,
]

task :validate_output do
      puts '---> parser validate'
end

task :spec_output do
      puts '---> spec'
end

task :lint_output do
      puts '---> puppet-lint'
end

task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
end
