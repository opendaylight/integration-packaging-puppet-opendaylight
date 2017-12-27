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

  file { 'org.ops4j.pax.web.cfg':
    ensure => file,
    path   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
    # Set user:group owners
    owner  => 'odl',
    group  => 'odl',
  }

  $ha_node_count = count($::opendaylight::ha_node_ips)
  if $::opendaylight::enable_ha and $ha_node_count < 2 {
    fail("Number of HA nodes less than 2: ${ha_node_count} and HA Enabled")
  }

  # Configuration of ODL NB REST port to listen on
  if $opendaylight::enable_tls {

    if $::opendaylight::tls_keystore_password == undef {
      fail('Enabling TLS requires setting a TLS password for the ODL keystore')
    }

    if $::opendaylight::tls_key_file or $::opendaylight::tls_cert_file {
      if $::opendaylight::tls_key_file and $::opendaylight::tls_cert_file {
        odl_keystore { 'controller':
          password  => $::opendaylight::tls_keystore_password,
          cert_file => $::opendaylight::tls_cert_file,
          key_file  => $::opendaylight::tls_key_file,
          ca_file   => $::opendaylight::tls_ca_cert_file,
          require   => File['/opt/opendaylight/configuration/ssl']
        }
      } else {
        fail('Must specify both TLS key file path AND certificate file path')
      }
    }

    augeas {'Remove HTTP ODL REST Port':
      incl    => '/opt/opendaylight/etc/jetty.xml',
      context => '/files/opt/opendaylight/etc/jetty.xml/Configure',
      lens    => 'Xml.lns',
      changes => ["rm Call[2]/Arg/New/Set[#attribute[name='port']]"]
    }

    augeas {'ODL SSL REST Port':
      incl    => '/opt/opendaylight/etc/jetty.xml',
      context => '/files/opt/opendaylight/etc/jetty.xml/Configure',
      lens    => 'Xml.lns',
      changes => ["set New[2]/Set[#attribute[name='securePort']]/Property/#attribute/default ${opendaylight::odl_rest_port}"]
    }

    file_line { 'set pax TLS port':
      ensure  => present,
      path    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      line    => "org.osgi.service.http.port.secure = ${opendaylight::odl_rest_port}",
      match   => '^#?org.osgi.service.http.port.secure.*$',
      require => File['org.ops4j.pax.web.cfg']
    }

    file_line { 'enable pax TLS':
      ensure  => present,
      path    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      line    => 'org.osgi.service.http.secure.enabled = true',
      match   => '^#?org.osgi.service.http.secure.enabled.*$',
      require => File['org.ops4j.pax.web.cfg']
    }

    file {'aaa-cert-config.xml':
      ensure  => file,
      path    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/aaa-cert-config.xml',
      owner   => 'odl',
      group   => 'odl',
      content => template('opendaylight/aaa-cert-config.xml.erb'),
    }

    file_line {'set pax TLS keystore location':
      ensure  => present,
      path    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      line    => 'org.ops4j.pax.web.ssl.keystore = configuration/ssl/ctl.jks',
      match   => '^#?org.ops4j.pax.web.ssl.keystore.*$',
      require => File['org.ops4j.pax.web.cfg']
    }
    file_line {'set pax TLS keystore integrity password':
      ensure  => present,
      path    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      line    => "org.ops4j.pax.web.ssl.password = ${opendaylight::tls_keystore_password}",
      match   => '^#?org.ops4j.pax.web.ssl.password.*$',
      require => File['org.ops4j.pax.web.cfg']
    }

    file_line {'set pax TLS keystore password':
      ensure  => present,
      path    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      line    => "org.ops4j.pax.web.ssl.keypassword = ${opendaylight::tls_keystore_password}",
      match   => '^#?org.ops4j.pax.web.ssl.keypassword.*$',
      require => File['org.ops4j.pax.web.cfg']
    }

    # Enable TLS with OVSDB
    file { 'org.opendaylight.ovsdb.library.cfg':
      ensure => file,
      path   => '/opt/opendaylight/etc/org.opendaylight.ovsdb.library.cfg',
      owner  => 'odl',
      group  => 'odl',
      source => 'puppet:///modules/opendaylight/org.opendaylight.ovsdb.library.cfg',
    }

    # Configure OpenFlow plugin to use TLS
    $transport_protocol = 'TLS'
  } else {
    $transport_protocol = 'TCP'
    augeas { 'ODL REST Port':
      incl    => '/opt/opendaylight/etc/jetty.xml',
      context => '/files/opt/opendaylight/etc/jetty.xml/Configure',
      lens    => 'Xml.lns',
      changes => [
        "set Call[2]/Arg/New/Set[#attribute[name='port']]/Property/#attribute/default
          ${opendaylight::odl_rest_port}"]
    }
  }
  # Configure OpenFlow plugin to use TCP/TLS
  file { 'default-openflow-connection-config.xml':
    ensure  => file,
    path    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/default-openflow-connection-config.xml',
    # Set user:group owners
    owner   => 'odl',
    group   => 'odl',
    content => template('opendaylight/default-openflow-connection-config.xml.erb'),
  }
  $initial_config_dir = '/opt/opendaylight/configuration/initial'

  file { $initial_config_dir:
        ensure => directory,
        mode   => '0755',
        owner  => 'odl',
        group  => 'odl',
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

    file_line { 'set pax bind IP':
      ensure  => present,
      path    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
      line    => "org.ops4j.pax.web.listening.addresses = ${opendaylight::odl_bind_ip}",
      require => File['org.ops4j.pax.web.cfg']
    }

    # Configure websocket address
    file { '/opt/opendaylight/etc/org.opendaylight.restconf.cfg':
      ensure => file,
      path   => '/opt/opendaylight/etc/org.opendaylight.restconf.cfg',
      owner  => 'odl',
      group  => 'odl',
    }
    -> file_line { 'websocket-address':
      ensure => present,
      path   => '/opt/opendaylight/etc/org.opendaylight.restconf.cfg',
      line   => "websocket-address=${::opendaylight::odl_bind_ip}",
      match  => '^websocket-address=.*$',
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

  # set logging mechanism
  if $opendaylight::log_mechanism == 'console' {
    file_line {'rootlogger':
      ensure => present,
      path   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      line   => 'log4j.rootLogger=INFO, stdout, osgi:*',
      match  => '^log4j.rootLogger.*$'
    }
    file_line { 'logappender':
      ensure             => present,
      path               => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      line               => 'log4j.appender.stdout.direct=true',
      after              => 'log4j.appender.stdout=org.apache.log4j.ConsoleAppender',
      match              => '^log4j.appender.stdout.direct.*$',
      append_on_no_match => true
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
  if $::opendaylight::enable_ha {
    # Configure ODL OSVDB Clustering

    file {'akka.conf':
      ensure  => file,
      path    => "${initial_config_dir}/akka.conf",
      owner   => 'odl',
      group   => 'odl',
      content => template('opendaylight/akka.conf.erb'),
      require => File[$initial_config_dir]
    }

    file {'modules.conf':
      ensure  => file,
      path    => "${initial_config_dir}/modules.conf",
      owner   => 'odl',
      group   => 'odl',
      content => template('opendaylight/modules.conf.erb'),
      require => File[$initial_config_dir]
    }

    file {'module-shards.conf':
      ensure  => file,
      path    => "${initial_config_dir}/module-shards.conf",
      owner   => 'odl',
      group   => 'odl',
      content => template('opendaylight/module-shards.conf.erb'),
      require => File[$initial_config_dir]
    }
  }

  $odl_dirs = [
    '/opt/opendaylight/etc/opendaylight',
    '/opt/opendaylight/etc/opendaylight/karaf',
    '/opt/opendaylight/etc/opendaylight/datastore',
    '/opt/opendaylight/etc/opendaylight/datastore/initial',
    '/opt/opendaylight/etc/opendaylight/datastore/initial/config',
    '/opt/opendaylight/configuration/ssl'
  ]

  file { $odl_dirs:
    ensure => directory,
    mode   => '0755',
    owner  => 'odl',
    group  => 'odl',
  }

  if ('odl-netvirt-openstack' in $opendaylight::features or 'odl-netvirt-sfc' in $opendaylight::features) {
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
