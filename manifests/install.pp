# == Class opendaylight::install
#
# Manages the installation of OpenDaylight.
#
# There are two install methods: RPM-based and deb-based. The resulting
# system state should be functionally equivalent.
#
class opendaylight::install {

  if $::opendaylight::manage_repositories {
    require ::opendaylight::repos
  }

  package { 'opendaylight':
    ensure  => present,
  }

}
