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

# CentOS Nexus VM
desc "Beaker tests against CentOS 7 VM with latest Oxygen testing RPM from ODL Nexus repo"
task :cent_8test_nexus_vm do
  sh "RS_SET=centos-7 RPM_REPO='https://nexus.opendaylight.org/content/repositories/opendaylight-oxygen-epel-7-$basearch-devel' bundle exec rake beaker"
end

# CentOS Nexus Container
desc "Beaker tests against CentOS 7 container with latest Oxygen testing RPM from ODL Nexus repo"
task :cent_8test_nexus_dock do
  sh "RS_SET=centos-7-docker RPM_REPO='https://nexus.opendaylight.org/content/repositories/opendaylight-oxygen-epel-7-$basearch-devel' bundle exec rake beaker"
end

# CentOS CBS VM
desc "Beaker tests against CentOS 7 VM with latest Oxygen testing RPM from CentOS CBS repo"
task :cent_8test_cbs_vm do
  sh "RS_SET=centos-7 RPM_REPO='http://cbs.centos.org/repos/nfv7-opendaylight-8-testing/$basearch/os/' bundle exec rake beaker"
end

# CentOS CBS Container
desc "Beaker tests against CentOS 7 container with latest Oxygen testing RPM from CentOS CBS repo"
task :cent_8test_cbs_dock do
  sh "RS_SET=centos-7-docker RPM_REPO='http://cbs.centos.org/repos/nfv7-opendaylight-8-testing/$basearch/os/' bundle exec rake beaker"
end

# Ubuntu VMs
#desc "Beaker tests against Ubuntu 16.04 Container with Nitrogen release Deb"
#task :ubuntu_6test_vm do
#  sh "RS_SET=ubuntu-16 DEB_REPO='ppa:odl-team/nitrogen' bundle exec rake beaker"
#end

# Ubuntu Containers
#desc "Beaker tests against Ubuntu 16.04 Container with Nitrogen release Deb"
#task :ubuntu_6test_dock do
#  sh "RS_SET=ubuntu-16-docker DEB_REPO='ppa:odl-team/nitrogen' bundle exec rake beaker"
#end

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
  :cent_8test_nexus_dock,
]

desc "All tests, use VMs for Beaker tests"
task :acceptance_vm => [
  :test,
  :cent_8test_cbs_vm,
  :cent_8test_nexus_vm,
]

desc "All tests, use containers for Beaker tests"
task :acceptance_dock => [
  :test,
  :cent_8test_cbs_dock,
  :cent_8test_nexus_dock,
]
