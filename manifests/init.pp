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
#   IP for ODL northbound REST interface and southbound OVSDB/OpenFlow to bind to.
# [*rpm_repo*]
#   Repo URL to install ODL RPM from, in .repo baseurl format.
# [*deb_repo*]
#   OpenDaylight Launchpad PPA repo to install .deb from (ppa:odl-team/carbon,
#   ppa:odl-team/nitrogen, ...).
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
#   Sets Java options for ODL in a string format. Defaults to ''.
# [*manage_repositories*]
#   (Boolean) Should this module manage the apt or yum repositories for the
#   package installation.
#   Defaults to true
# [*log_max_size*]
#   Maxium size of OpenDaylight's log file.
# [*log_max_rollover*]
#   Maxium number of OpenDaylight log rollovers to keep.
# [*log_rollover_fileindex*]
#   File index to use for OpenDaylight log rollovers
#   Defaults to 'min'.
#   Other possible values: 'max', 'nomax'
#   see https://logging.apache.org/log4j/2.x/manual/appenders.html#FileAppender for more info
# [*snat_mechanism*]
#   Sets the mechanism to be used for SNAT (conntrack, controller)
# [*enable_tls*]
#   (Boolean) Enables TLS for REST and OpenFlow/OVSDB with OpenDaylight.
#   Defaults to false
# [*tls_keystore_password*]
#   TLS keystore password.  Required when enabling TLS.
# [*tls_trusted_certs*]
#   An array of cert files to be added to OpenDaylight's trusted keystore.
#   Optional.  Defaults to None.
# [*tls_key_file*]
#   Full path to a private key file to be used for OpenDaylight.
#   Optional.  Defaults to undef.  Requires setting tls_cert_file.
# [*tls_cert_file*]
#   Full path to a public certificate file to be used for OpenDaylight.
#   Optional.  Defaults to undef.  Requires setting tls_key_file.
# [*tls_ca_cert_file*]
#   Full path to a public CA authority certificate file which signed
#   OpenDaylight's certificate.  Not needed if ODL certificate is self-signed.
#   Optional.  Defaults to undef.
# [*log_mechanism*]
#   Sets logging mechanism for karaf logs
# [*inherit_dscp_marking*]
#   Sets tos option to enable QoS DSCP marking
#   Defaults to false
# [*stats_polling_enabled*]
#   Enables statistics polling of OpenFlow entities like table, groups.
#   Defaults to false
# [*inactivity_probe*]
#   Time in millseconds before an inactivity probe is sent via OVSDB
#   to OVS. Defaults to undef.
#
# === Deprecated Parameters
#
# [*ha_node_index*]
#   Index of ha_node_ips for this node.
#
class opendaylight (
  $default_features       = $::opendaylight::params::default_features,
  $extra_features         = $::opendaylight::params::extra_features,
  $odl_rest_port          = $::opendaylight::params::odl_rest_port,
  $odl_bind_ip            = $::opendaylight::params::odl_bind_ip,
  $rpm_repo               = $::opendaylight::params::rpm_repo,
  $deb_repo               = $::opendaylight::params::deb_repo,
  $log_levels             = $::opendaylight::params::log_levels,
  $enable_ha              = $::opendaylight::params::enable_ha,
  $ha_node_ips            = $::opendaylight::params::ha_node_ips,
  $ha_node_index          = $::opendaylight::params::ha_node_index,
  $java_opts              = $::opendaylight::params::java_opts,
  $ha_db_modules          = $::opendaylight::params::ha_db_modules,
  $vpp_routing_node       = $::opendaylight::params::vpp_routing_node,
  $manage_repositories    = $::opendaylight::params::manage_repositories,
  $username               = $::opendaylight::params::username,
  $password               = $::opendaylight::params::password,
  $log_max_size           = $::opendaylight::params::log_max_size,
  $log_max_rollover       = $::opendaylight::params::log_max_rollover,
  $log_rollover_fileindex = $::opendaylight::params::log_rollover_fileindex,
  $snat_mechanism         = $::opendaylight::params::snat_mechanism,
  $enable_tls             = $::opendaylight::params::enable_tls,
  $tls_keystore_password  = $::opendaylight::params::tls_keystore_password,
  $tls_trusted_certs      = $::opendaylight::params::tls_trusted_certs,
  $tls_key_file           = $::opendaylight::params::tls_key_file,
  $tls_cert_file          = $::opendaylight::params::tls_cert_file,
  $tls_ca_cert_file       = $::opendaylight::params::tls_ca_cert_file,
  $log_mechanism          = $::opendaylight::params::log_mechanism,
  $inherit_dscp_marking   = $::opendaylight::params::inherit_dscp_marking,
  $stats_polling_enabled  = $::opendaylight::params::stats_polling_enabled,
  $inactivity_probe       = $::opendaylight::params::inactivity_probe,
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

  if $opendaylight::odl_bind_ip =~ Stdlib::Compat::Ipv6 {
    $enable_ipv6 = true
    $java_options = strip(join(union(['-Djava.net.preferIPv6Addresses=true'], any2array($opendaylight::java_opts)), ' '))
  }
  else {
    $enable_ipv6 = false
    $java_options = strip(join(union(['-Djava.net.preferIPv4Stack=true'], any2array($opendaylight::java_opts)), ' '))
  }

  class { '::opendaylight::install': }
  -> class { '::opendaylight::config': }
  ~> class { '::opendaylight::service': }
  -> class { '::opendaylight::post_config': }
  -> Class['::opendaylight']
}
