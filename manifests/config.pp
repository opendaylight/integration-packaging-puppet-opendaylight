# == Class opendaylight::config
#
# This class handles ODL config changes.
# It's called from the opendaylight class.
#
class opendaylight::config {
  # Configuration of Karaf features to install
  file { 'org.apache.karaf.features.cfg':
    ensure => file,
    path   => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
    # Set user:group owners
    owner  => 'odl',
    group  => 'odl',
  }
  $features_csv = join($opendaylight::features, ',')
  file_line { 'featuresBoot':
    path  => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
    line  => "featuresBoot=${features_csv}",
    match => '^featuresBoot=.*$',
  }

  # Configuration of ODL NB REST port to listen on
  augeas {'ODL REST Port':
    incl    => '/opt/opendaylight/etc/jetty.xml',
    context => '/files/opt/opendaylight/etc/jetty.xml/Configure',
    lens    => 'Xml.lns',
    changes => [
      "set Call[2]/Arg/New/Set[#attribute[name='port']]/Property/#attribute/default ${opendaylight::odl_rest_port}"]
  }

  if $opendaylight::odl_bind_ip != '0.0.0.0' {
    # Configuration of ODL NB REST IP to listen on
    augeas { 'ODL REST IP':
      incl    => '/opt/opendaylight/etc/jetty.xml',
      context => '/files/opt/opendaylight/etc/jetty.xml/Configure',
      lens    => 'Xml.lns',
      changes => [
        "set Call[1]/Arg/New/Set[#attribute[name='host']]/Property/#attribute/default ${opendaylight::odl_bind_ip}",
        "set Call[2]/Arg/New/Set[#attribute[name='host']]/Property/#attribute/default ${opendaylight::odl_bind_ip}"]
    }

    file { 'org.ops4j.pax.web.cfg':
      ensure => file,
      path   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      # Set user:group owners
      owner  => 'odl',
      group  => 'odl',
    }
    -> file_line { 'org.ops4j.pax.web.cfg':
      ensure => present,
      path   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      line   => "org.ops4j.pax.web.listening.addresses = ${opendaylight::odl_bind_ip}"
    }
  }

  # Set any custom log levels
  $opendaylight::log_levels.each |$log_name, $logging_level| {
    file_line {"logger-${log_name}":
      ensure => present,
      path   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      line   => "log4j.logger.${log_name}=${logging_level}"
    }
  }

  # Set maximum ODL log file size
  file_line { 'logmaxsize':
    ensure => present,
    path   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
    line   => "log4j.appender.out.maxFileSize=${::opendaylight::log_max_size}",
    match  => '^log4j.appender.out.maxFileSize.*$'
  }

  # Set maximum number of ODL log file rollovers to preserve
  file_line { 'logmaxrollover':
    ensure => present,
    path   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
    line   => "log4j.appender.out.maxBackupIndex=${::opendaylight::log_max_rollover}",
    match  => '^log4j.appender.out.maxBackupIndex.*$'
  }

  # Configure ODL HA if enabled
  $ha_node_count = count($::opendaylight::ha_node_ips)
  if $::opendaylight::enable_ha {
    if $ha_node_count >= 2 {
      # Configure ODL OSVDB Clustering
      $cluster_config_dir = '/opt/opendaylight/configuration/initial'

      file { $cluster_config_dir:
        ensure => directory,
        mode   => '0755',
        owner  => 'odl',
        group  => 'odl',
      }

      file {'akka.conf':
        ensure  => file,
        path    => "${cluster_config_dir}/akka.conf",
        owner   => 'odl',
        group   => 'odl',
        content => template('opendaylight/akka.conf.erb'),
        require => File[$cluster_config_dir]
      }

      file {'modules.conf':
        ensure  => file,
        path    => "${cluster_config_dir}/modules.conf",
        owner   => 'odl',
        group   => 'odl',
        content => template('opendaylight/modules.conf.erb'),
        require => File[$cluster_config_dir]
      }

      file {'module-shards.conf':
        ensure  => file,
        path    => "${cluster_config_dir}/module-shards.conf",
        owner   => 'odl',
        group   => 'odl',
        content => template('opendaylight/module-shards.conf.erb'),
        require => File[$cluster_config_dir]
      }

    } else {
      fail("Number of HA nodes less than 2: ${ha_node_count} and HA Enabled")
    }
  }

  if ('odl-netvirt-openstack' in $opendaylight::features or 'odl-netvirt-sfc' in $opendaylight::features) {
    # Configure ACL security group
    # Requires at least CentOS 7.3 for RHEL/CentOS systems
    if $opendaylight::security_group_mode == 'stateful' {
      if defined('$opendaylight::stateful_unsupported') and $opendaylight::stateful_unsupported {
          warning("Stateful is unsupported in ${::operatingsystemrelease} setting to 'learn'")
          $sg_mode = 'learn'
      } else {
        $sg_mode = 'stateful'
      }
    } else {
      $sg_mode = $opendaylight::security_group_mode
    }

    $odl_datastore = [
      '/opt/opendaylight/etc/opendaylight',
      '/opt/opendaylight/etc/opendaylight/datastore',
      '/opt/opendaylight/etc/opendaylight/datastore/initial',
      '/opt/opendaylight/etc/opendaylight/datastore/initial/config',
    ]

    file { $odl_datastore:
      ensure => directory,
      mode   => '0755',
      owner  => 'odl',
      group  => 'odl',
    }
    -> file { 'netvirt-aclservice-config.xml':
      ensure  => file,
      path    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/netvirt-aclservice-config.xml',
      owner   => 'odl',
      group   => 'odl',
      content => template('opendaylight/netvirt-aclservice-config.xml.erb'),
    }

    # Configure SNAT
    file { 'netvirt-natservice-config.xml':
      ensure  => file,
      path    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/netvirt-natservice-config.xml',
      owner   => 'odl',
      group   => 'odl',
      content => template('opendaylight/netvirt-natservice-config.xml.erb'),
      require => File['/opt/opendaylight/etc/opendaylight/datastore/initial/config'],
    }
  }

  # SFC Config
  if ('odl-netvirt-sfc' in $opendaylight::features) {
    file { 'netvirt-elanmanager-config.xml':
      ensure  => file,
      path    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/netvirt-elanmanager-config.xml',
      owner   => 'odl',
      group   => 'odl',
      source  => 'puppet:///modules/opendaylight/netvirt-elanmanager-config.xml',
      require => File['/opt/opendaylight/etc/opendaylight/datastore/initial/config'],
    }

    file { 'genius-itm-config.xml':
      ensure  => file,
      path    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/genius-itm-config.xml',
      owner   => 'odl',
      group   => 'odl',
      source  => 'puppet:///modules/opendaylight/genius-itm-config.xml',
      require => File['/opt/opendaylight/etc/opendaylight/datastore/initial/config'],
    }
  }

  #configure VPP routing node
  if ! empty($::opendaylight::vpp_routing_node) {
    file { 'org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg':
      ensure => file,
      path   => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg',
      owner  => 'odl',
      group  => 'odl',
    }
    file_line { 'routing-node':
      path  => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg',
      line  => "routing-node=${::opendaylight::vpp_routing_node}",
      match => '^routing-node=.*$',
    }
  }

  # Configure username/password
  odl_user { $::opendaylight::username:
    password => $::opendaylight::password,
    before   => Service['opendaylight'],
  }
}
