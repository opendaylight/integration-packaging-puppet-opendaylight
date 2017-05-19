# Temporary fix for error caused by third party gems. See:
# https://github.com/maestrodev/puppet-blacksmith/issues/14
# https://github.com/dfarrell07/puppet-opendaylight/issues/6
require 'puppet/version'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f <3.6

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# on Travis with `--without local_only`
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

PuppetLint.configuration.relative = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{line}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

exclude_paths = [
  "bundle/**/*",
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

# Linting

task :metadata_lint do
  sh "metadata-json-lint metadata.json"
end

task :travis_lint do
  # Using "echo y" to accept interactive "install shell completion?" prompt
  sh 'echo "y" | travis lint .travis.yml --debug'
end

# CentOS VMs

desc "Beaker tests against CentOS 7 VM with latest Carbon testing RPM"
task :cent_6test_vm do
  sh "RS_SET=centos-7 RPM_REPO='opendaylight-6-testing' bundle exec rake beaker"
end

# CentOS Containers

desc "Beaker tests against CentOS 7 container with latest Carbon testing RPM"
task :cent_6test_dock do
  sh "RS_SET=centos-7-docker RPM_REPO='opendaylight-6-testing' bundle exec rake beaker"
end

# Ubuntu VMs

# TODO: Add ubuntu_6test_dock task

# Ubuntu Containers

# TODO: Add ubuntu_6test_dock task

# Multi-test helpers

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :metadata_lint,
  :travis_lint,
  :spec,
]

desc "Quick and important tests"
task :sanity=> [
  :test,
  :cent_6test_dock,
]

# TODO: Update .deb to Carbon and add a ubuntu_6test_vm test
desc "All tests, use VMs for Beaker tests"
task :acceptance_vm => [
  :test,
  :cent_6test_vm,
]

# TODO: Update .deb to Carbon and add a ubuntu_6test_dock test
desc "All tests, use containers for Beaker tests"
task :acceptance_dock => [
  :test,
  :cent_6test_dock,
]
