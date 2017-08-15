require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

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

desc "Beaker tests against Ubuntu 16.04 Container with Boron release Deb"
task :ubuntu_6test_vm do
  sh "RS_SET=ubuntu-16 DEB_REPO='ppa:odl-team/carbon' bundle exec rake beaker"
end

# Ubuntu Containers

desc "Beaker tests against Ubuntu 16.04 Container with Boron release Deb"
task :ubuntu_6test_dock do
  sh "RS_SET=ubuntu-16-docker DEB_REPO='ppa:odl-team/carbon' bundle exec rake beaker"
end

# Multi-test helpers

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :metadata_lint,
  :spec,
]

desc "Quick and important tests"
task :sanity=> [
  :test,
  :cent_6test_dock,
]

desc "All tests, use VMs for Beaker tests"
task :acceptance_vm => [
  :test,
  :ubuntu_6test_vm,
  :cent_6test_vm,
]

desc "All tests, use containers for Beaker tests"
task :acceptance_dock => [
  :test,
  :ubuntu_6test_dock,
  :cent_6test_dock,
]
