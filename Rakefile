require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetLint.configuration.relative = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{line}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

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

# CentOS latest VM
desc "Beaker tests against CentOS 7 VM with latest Oxygen RPM from ODL Nexus CD repo"
task :cent_devel_vm do
  sh "RS_SET=centos-7 RPM_REPO='https://nexus.opendaylight.org/content/repositories/opendaylight-oxygen-epel-7-$basearch-devel' bundle exec rake beaker"
end

# CentOS latest container
desc "Beaker tests against CentOS 7 container with latest Oxygen RPM from ODL Nexus CD repo"
task :cent_devel_dock do
  sh "RS_SET=centos-7-docker RPM_REPO='https://nexus.opendaylight.org/content/repositories/opendaylight-oxygen-epel-7-$basearch-devel' bundle exec rake beaker"
end

# CentOS latest release/SR VM
desc "Beaker tests against CentOS 7 VM with latest Oxygen release/SR RPM from CentOS CBS repo"
task :cent_rel_vm do
  sh "RS_SET=centos-7 RPM_REPO='http://cbs.centos.org/repos/nfv7-opendaylight-8-release/$basearch/os/' bundle exec rake beaker"
end

# CentOS latest release/SR container
desc "Beaker tests against CentOS 7 container with latest Oxygen release/SR RPM from CentOS CBS repo"
task :cent_rel_dock do
  sh "RS_SET=centos-7-docker RPM_REPO='http://cbs.centos.org/repos/nfv7-opendaylight-8-release/$basearch/os/' bundle exec rake beaker"
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
  :cent_devel_dock,
]

desc "All tests, use VMs for Beaker tests"
task :acceptance_vm => [
  :test,
  :cent_devel_vm,
  :cent_rel_vm,
]

desc "All tests, use containers for Beaker tests"
task :acceptance_dock => [
  :test,
  :cent_devel_dock,
  :cent_rel_dock,
]
