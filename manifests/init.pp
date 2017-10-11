# == Class: opendaylight
#
# OpenDaylight SDN Controller
#
# === Parameters
# [*default_features*]
#   Features that should normally be installed by default, but can be
#   overridden.
# [*extra_features*]
#   List of features to install in addition to the default ones.
# [*odl_rest_port *]
#   Port for ODL northbound REST interface to listen on.
# [*odl_bind_ip *]
#   IP for ODL northbound REST interface to bind to.
# [*rpm_repo*]
#   OpenDaylight CentOS CBS repo to install RPM from (opendaylight-4-testing,
#   opendaylight-40-release, ...).
# [*deb_repo*]
#   OpenDaylight Launchpad PPA repo to install .deb from (ppa:odl-team/boron,
#   ppa:odl-team/carbon, ...).
# [*log_levels*]
#   Custom OpenDaylight logger verbosity configuration (TRACE, DEBUG, INFO, WARN, ERROR).
# [*enable_ha*]
#   Enable or disable ODL OVSDB HA Clustering. Valid: true or false.
#   Default: false.
# [*ha_node_ips*]
#   Array of IPs for each node in the HA cluster.
# [*ha_db_modules*]
#   Hash of modules and Yang namespaces to create database shards.  Defaults to
#   { 'default' => false }.  "default" module does not need a namespace.
# [*vpp_routing_node*]
#   Sets routing node for VPP deployments. Defaults to ''.
# [*java_opts*]
#   Sets Java options for ODL in a string format. Defaults to '-Djava.net.preferIPv4Stack=true'.
# [*manage_repositories*]
#   (Boolean) Should this module manage the apt or yum repositories for the
#   package installation.
#   Defaults to true
# [*log_max_size*]
#   Maxium size of OpenDaylight's log file.
# [*log_max_rollover*]
#   Maxium number of OpenDaylight log rollovers to keep.
# [*snat_mechanism*]
#   Sets the mechanism to be used for SNAT (conntrack, controller)
#
# === Deprecated Parameters
#
# [*ha_node_index*]
#   Index of ha_node_ips for this node.
#
class opendaylight (
  $default_features    = $::opendaylight::params::default_features,
  $extra_features      = $::opendaylight::params::extra_features,
  $odl_rest_port       = $::opendaylight::params::odl_rest_port,
  $odl_bind_ip         = $::opendaylight::params::odl_bind_ip,
  $rpm_repo            = $::opendaylight::params::rpm_repo,
  $deb_repo            = $::opendaylight::params::deb_repo,
  $log_levels          = $::opendaylight::params::log_levels,
  $enable_ha           = $::opendaylight::params::enable_ha,
  $ha_node_ips         = $::opendaylight::params::ha_node_ips,
  $ha_node_index       = $::opendaylight::params::ha_node_index,
  $ha_db_modules       = $::opendaylight::params::ha_db_modules,
  $vpp_routing_node    = $::opendaylight::params::vpp_routing_node,
  $java_opts           = $::opendaylight::params::java_opts,
  $manage_repositories = $::opendaylight::params::manage_repositories,
  $username            = $::opendaylight::params::username,
  $password            = $::opendaylight::params::password,
  $log_max_size        = $::opendaylight::params::log_max_size,
  $log_max_rollover    = $::opendaylight::params::log_max_rollover,
  $snat_mechanism      = $::opendaylight::params::snat_mechanism
) inherits ::opendaylight::params {

  # Validate OS family
  case $::osfamily {
    'RedHat': {}
    'Debian': {
        warning('Debian has limited support, is less stable, less tested.')
    }
    default: {
        fail("Unsupported OS family: ${::osfamily}")
    }
  }

  # Validate OS
  case $::operatingsystem {
    centos, redhat: {
      if $::operatingsystemmajrelease != '7' {
        # RHEL/CentOS versions < 7 not supported as they lack systemd
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    fedora: {
      # Fedora distros < 24 are EOL as of 2016-12-20
      # https://fedoraproject.org/wiki/End_of_life
      if $::operatingsystemmajrelease < '24' {
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      } else {
        warning('Fedora is not as well tested as CentOS.')
      }
    }
    ubuntu: {
      if $::operatingsystemrelease < '16.04' {
        # Only tested on 16.04
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemrelease}")
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
  # Build full list of features to install
  $features = union($default_features, $extra_features)

  class { '::opendaylight::install': }
  -> class { '::opendaylight::config': }
  ~> class { '::opendaylight::service': }
  -> Class['::opendaylight']
}
