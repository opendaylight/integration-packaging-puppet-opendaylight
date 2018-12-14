require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

# Customize filters to ignore 3rd-party code
# If the rspec coverage report shows not-our-code results, add it here
custom_filters = [
]
RSpec::Puppet::Coverage.filters.push(*custom_filters)

#
# NB: This is a library of helper fns used by the rspec-puppet tests
#

# Tests that are common to all possible configurations
def generic_tests(options = {})
  java_opts = options.fetch(:java_opts, '')
  odl_bind_ip = options.fetch(:odl_bind_ip, '0.0.0.0')
  inactivity_probe = options.fetch(:inactivity_probe, :undef)

  # Confirm that module compiles
  it { should compile }
  it { should compile.with_all_deps }

  # Confirm presence of classes
  it { should contain_class('opendaylight') }
  it { should contain_class('opendaylight::params') }
  it { should contain_class('opendaylight::install') }
  it { should contain_class('opendaylight::config') }
  it { should contain_class('opendaylight::post_config') }
  it { should contain_class('opendaylight::service') }

  # Confirm relationships between classes
  it { should contain_class('opendaylight::install').that_comes_before('Class[opendaylight::config]') }
  it { should contain_class('opendaylight::config').that_requires('Class[opendaylight::install]') }
  it { should contain_class('opendaylight::config').that_notifies('Class[opendaylight::service]') }
  it { should contain_class('opendaylight::service').that_subscribes_to('Class[opendaylight::config]') }
  it { should contain_class('opendaylight::service').that_comes_before('Class[opendaylight]') }
  it { should contain_class('opendaylight::post_config').that_requires('Class[opendaylight::service]') }
  it { should contain_class('opendaylight::post_config').that_comes_before('Class[opendaylight]') }
  it { should contain_class('opendaylight').that_requires('Class[opendaylight::service]') }

  # Confirm presence of generic resources
  it { should contain_service('opendaylight') }
  it { should contain_file('org.apache.karaf.features.cfg') }

  # Confirm properties of generic resources
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_service('opendaylight').with(
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
    )
  }
  it {
    should contain_file('org.apache.karaf.features.cfg').with(
      'ensure'      => 'file',
      'path'        => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
      'owner'   => 'odl',
      'group'   => 'odl',
    )
  }

  it {
    if odl_bind_ip =~ /.*:.*/
        java_options = '-Djava.net.preferIPv6Addresses=true'
    else
        java_options = '-Djava.net.preferIPv4Stack=true'
    end

    should contain_file_line('Karaf Java Options').with(
      'ensure' => 'present',
      'path'   => '/opt/opendaylight/bin/karaf',
      'line'   => "EXTRA_JAVA_OPTS=\"#{java_options}\"",
      'match'  => '^EXTRA_JAVA_OPTS=.*$',
      'after'  => '^PROGNAME=.*$'
    )
  }

  it {
    should contain_file('org.opendaylight.ovsdb.library.cfg').with(
      'ensure'  => 'file',
      'path'    => '/opt/opendaylight/etc/org.opendaylight.ovsdb.library.cfg',
      'owner'   => 'odl',
      'group'   => 'odl',
      'content' =>  /ovsdb-listener-ip = #{odl_bind_ip}/
    )
  }

  it {
    should contain_file('default-openflow-connection-config.xml').with(
      'ensure'  => 'file',
      'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/default-openflow-connection-config.xml',
      'owner'   => 'odl',
      'group'   => 'odl',
      'content' =>  /<address>#{odl_bind_ip}<\/address>/
    )
  }

  unless inactivity_probe == :undef
    it {
      should contain_file('Configure inactivity probe timer').with(
        'ensure'  => 'file',
        'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/netvirt-elanmanager-config.xml',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content' =>  /<controller-inactivity-probe>#{inactivity_probe}<\/controller-inactivity-probe>/
      )
    }
  end

end

# Shared tests that specialize in testing log file size and rollover
def log_settings(options = {})
  # Extraxt params. The dafault value should be same as in opendaylight::params
  log_max_size = options.fetch(:log_max_size, '10GB')
  log_max_rollover = options.fetch(:log_max_rollover, 2)
  log_rollover_fileindex = options.fetch(:log_rollover_fileindex, 'min')
  log_pattern = options.fetch(:log_pattern, '%d{ISO8601} | %-5p | %-16t | %-60c{6} | %m%n')
  log_mechanism = options.fetch(:log_mechanism, 'file')
  enable_paxosgi_logger = options.fetch(:enable_paxosgi_logger, false)

  if log_mechanism == 'console'
    it {
      should contain_file_line('consoleappender').with(
        'path'  => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'  => 'karaf.log.console=INFO',
        'after' => 'log4j2.rootLogger.appenderRef.Console.filter.threshold.type = ThresholdFilter',
        'match' => '^karaf.log.console.*$'
      )
    }
    it {
      should contain_file_line('direct').with(
        'path'  => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'  => 'log4j2.appender.console.direct = true',
        'after' => 'karaf.log.console=INFO',
        'match' => '^log4j2.appender.console.direct.*$'
      )
    }
  else

    it {
      should contain_file_line('logmaxsize').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'   => "log4j2.appender.rolling.policies.size.size = #{log_max_size}",
        'match'  => '^log4j2.appender.rolling.policies.size.size.*$',
      )
    }
    it {
      should contain_file_line('rolloverstrategy').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'   => 'log4j2.appender.rolling.strategy.type = DefaultRolloverStrategy'
      )
    }
    it {
      should contain_file_line('logmaxrollover').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'   => "log4j2.appender.rolling.strategy.max = #{log_max_rollover}",
        'match'  => '^log4j2.appender.rolling.strategy.max.*$',
      )
    }
    it {
      should contain_file_line('logrolloverfileindex').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'   => "log4j2.appender.rolling.strategy.fileIndex = #{log_rollover_fileindex}",
        'match'  => '^log4j2.appender.rolling.strategy.fileIndex.*$',
      )
    }
  end
  it {
    should contain_file_line('logpattern').with(
      'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      'line'   => "log4j2.pattern = #{log_pattern}",
      'match'  => '^log4j2.pattern.*$',
    )
  }
  if enable_paxosgi_logger == true
      presence = 'present'
  else
      presence = 'absent'
  end

  it {
    should contain_file_line('paxosgiappenderref').with(
      'ensure' => presence,
      'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      'line'   => "log4j2.rootLogger.appenderRef.PaxOsgi.ref = PaxOsgi",
    )
  }
  it {
    should contain_file_line('paxosgisection').with(
      'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      'line'   => "# OSGi appender",
    )
  }
  it {
    should contain_file_line('paxosgitype').with(
      'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      'line'   => "log4j2.appender.osgi.type = PaxOsgi",
    )
  }
  it {
    should contain_file_line('paxosginame').with(
      'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      'line'   => "log4j2.appender.osgi.name = PaxOsgi",
    )
  }
  it {
    should contain_file_line('paxosgifilter').with(
      'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
      'line'   => "log4j2.appender.osgi.filter = *",
    )
  }
end

# Shared tests that specialize in testing Karaf feature installs
def karaf_feature_tests(options = {})
  # Extract params
  # NB: This default list should be the same as the one in opendaylight::params
  default_features = options.fetch(:default_features, ['standard', 'wrap', 'ssh'])
  extra_features = options.fetch(:extra_features, [])

  # The order of this list concat matters
  features = default_features + extra_features
  features_csv = features.join(',')

  # Confirm properties of Karaf features config file
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_file('org.apache.karaf.features.cfg').with(
      'ensure'      => 'file',
      'path'        => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
      'owner'   => 'odl',
      'group'   => 'odl',
    )
  }
  it {
    should contain_file_line('featuresBoot').with(
      'path'  => '/opt/opendaylight/etc/org.apache.karaf.features.cfg',
      'line'  => "featuresBoot=#{features_csv}",
      'match' => '^featuresBoot=.*$',
    )
  }
end

# Shared tests that specialize in testing ODL's REST port config
def odl_rest_port_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  odl_rest_port = options.fetch(:odl_rest_port, 8181)
  odl_bind_ip = options.fetch(:odl_bind_ip, '0.0.0.0')
  # Confirm properties of ODL REST port config file
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_augeas('ODL REST Port')
  }

  if not odl_bind_ip.eql? '0.0.0.0'
    it {
      should contain_augeas('ODL REST IP')
      should contain_file_line('set pax bind IP').with(
        'ensure'  => 'present',
        'path'    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'    => "org.ops4j.pax.web.listening.addresses = #{odl_bind_ip}",
        'require' => 'File[org.ops4j.pax.web.cfg]'
      )
      should contain_file_line('set karaf IP').with(
        'ensure' => 'present',
        'path'   => '/opt/opendaylight/etc/org.apache.karaf.shell.cfg',
        'line'   => "sshHost = #{odl_bind_ip}",
        'match'  => '^sshHost\s*=.*$',
      )
    }
  else
    it {
      should_not contain_augeas('ODL REST IP')
    }
  end

  it {
    should contain_file_line('set pax bind port').with(
        'ensure'  => 'present',
        'path'    => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'    => "org.osgi.service.http.port = #{odl_rest_port}",
        'match'   => '^#?org.osgi.service.http.port\s.*$',
        'require' => 'File[org.ops4j.pax.web.cfg]'
    )
  }
end

def log_level_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  log_levels = options.fetch(:log_levels, {})

  if log_levels.empty?
    # Should contain log level config file
    it {
      should_not contain_file_line('logger-org.opendaylight.ovsdb-level')
    }
    it {
      should_not contain_file_line('logger-org.opendaylight.ovsdb-name')
    }
  else
    # Verify each custom log level config entry
    log_levels.each_pair do |logger, level|
      underscored_version = "#{logger}".gsub('.', '_')
      it {
        should contain_file_line("logger-#{logger}-level").with(
          'ensure' => 'present',
          'path' => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
          'line' => "log4j2.logger.#{underscored_version}.level = #{level}",
          'match'  => "log4j2.logger.#{underscored_version}.level = .*$"
        )
        should contain_file_line("logger-#{logger}-name").with(
          'ensure' => 'present',
          'path' => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
          'line' => "log4j2.logger.#{underscored_version}.name = #{logger}",
          'match'  => "log4j2.logger.#{underscored_version}.name = .*$"
        )
      }
    end
  end
end

def enable_ha_tests(options = {})
  # Extract params
  enable_ha = options.fetch(:enable_ha, false)
  odl_bind_ip = options.fetch(:odl_bind_ip, '0.0.0.0')
  ha_node_ips = options.fetch(:ha_node_ips, [])
  ha_db_modules = options.fetch(:ha_db_modules, { 'default' => false })
  # HA_NODE_IPS size
  ha_node_count = ha_node_ips.size

  if (enable_ha) && (ha_node_count < 2)
    # Check for HA_NODE_COUNT < 2
    fail("Number of HA nodes less than 2: #{ha_node_count} and HA Enabled")
  end

  if enable_ha
    ha_node_index = ha_node_ips.index(odl_bind_ip)
    it {
      should contain_file('akka.conf').with(
        'path'    => '/opt/opendaylight/configuration/initial/akka.conf',
        'ensure'  => 'file',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content' => /roles\s*=\s*\["member-#{ha_node_index}"\]/
      )
    }

    ha_db_modules.each do |mod, urn|
      it { should contain_file('module-shards.conf').with(
        'path'    => '/opt/opendaylight/configuration/initial/module-shards.conf',
        'ensure'  => 'file',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content' => /name = "#{mod}"/
      )}
      if mod == 'default'
        it { should contain_file('modules.conf').with(
          'path'    => '/opt/opendaylight/configuration/initial/modules.conf',
          'ensure'  => 'file',
          'owner'   => 'odl',
          'group'   => 'odl'
        )}
      else
        it { should contain_file('modules.conf').with(
          'path'    => '/opt/opendaylight/configuration/initial/modules.conf',
          'ensure'  => 'file',
          'owner'   => 'odl',
          'group'   => 'odl',
          'content' => /name = "#{mod}"/,
        )}
      end
    end
  else
    it {
      should_not contain_file('akka.conf')
      should_not contain_file('module-shards.conf')
      should_not contain_file('modules.conf')
      }
  end
end

def rpm_install_tests(options = {})
  # Extract params
  rpm_repo = options.fetch(:rpm_repo, 'https://nexus.opendaylight.org/content/repositories/opendaylight-neon-epel-7-$basearch-devel')


  # Default to CentOS 7 Yum repo URL

  # Confirm presence of RPM-related resources
  it { should contain_yumrepo('opendaylight') }
  it { should contain_package('opendaylight') }

  # Confirm relationships between RPM-related resources
  it { should contain_package('opendaylight').that_requires('Yumrepo[opendaylight]') }
  it { should contain_yumrepo('opendaylight').that_comes_before('Package[opendaylight]') }

  # Confirm properties of RPM-related resources
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_yumrepo('opendaylight').with(
      'enabled'     => '1',
      'gpgcheck'    => '0',
      'descr'       => 'OpenDaylight SDN Controller',
      'baseurl'     => "#{rpm_repo}",
    )
  }
  it {
    should contain_package('opendaylight').with(
      'ensure'   => 'present',
    )
  }
end

def deb_install_tests(options = {})
  # Extract params
  deb_repo = options.fetch(:deb_repo, 'ppa:odl-team/nitrogen')

  # Confirm the presence of Deb-related resources
  it { should contain_apt__ppa(deb_repo) }
  it { should contain_package('opendaylight') }

  # Confirm relationships between Deb-related resources
  it { should contain_package('opendaylight').that_requires("Apt::Ppa[#{deb_repo}]") }
  it { should contain_apt__ppa(deb_repo).that_comes_before('Package[opendaylight]') }

  # Confirm presence of Deb-related resources
  it {
    should contain_package('opendaylight').with(
      'ensure'   => 'present',
    )
  }
end

# Shared tests for unsupported OSs
def unsupported_os_tests(options = {})
  # Extract params
  expected_msg = options.fetch(:expected_msg)
  rpm_repo = options.fetch(:rpm_repo, 'https://nexus.opendaylight.org/content/repositories/opendaylight-neon-epel-7-$basearch-devel')

  # Confirm that classes fail on unsupported OSs
  it { expect { should contain_class('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::install') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::service') }.to raise_error(Puppet::Error, /#{expected_msg}/) }

  # Confirm that other resources fail on unsupported OSs
  it { expect { should contain_yumrepo('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_package('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_service('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_file('org.apache.karaf.features.cfg') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
end

# Shared tests that specialize in testing SNAT mechanism
def snat_mechanism_tests(snat_mechanism='controller')
  it { should contain_file('/opt/opendaylight/etc/opendaylight') }
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore')}
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore/initial')}
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore/initial/config')}

  # Confirm snat_mechanism
  it {
    should contain_file('netvirt-natservice-config.xml').with(
      'ensure'      => 'file',
      'path'        => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/netvirt-natservice-config.xml',
      'owner'   => 'odl',
      'group'   => 'odl',
      'content'     =>  /<nat-mode>#{snat_mechanism}<\/nat-mode>/
      )
    }
end

# Shared tests that specialize in testing SFC Config
def sfc_tests(options = {})
  extra_features = options.fetch(:extra_features, [])

  if extra_features.include? 'odl-netvirt-sfc'
    sfc_enabled = true
  else
    sfc_enabled = false
  end

  it { should contain_file('/opt/opendaylight/etc/opendaylight') }
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore')}
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore/initial')}
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore/initial/config')}

  it {
    should contain_file('genius-itm-config.xml').with(
      'ensure'  => 'file',
      'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/genius-itm-config.xml',
      'owner'   => 'odl',
      'group'   => 'odl',
      'content' => /<gpe-extension-enabled>#{sfc_enabled}<\/gpe-extension-enabled>/
      )
    }
end

# Shared tests that specialize in testing DSCP marking config
def dscp_tests(options = {})
  inherit_dscp_marking = options.fetch(:inherit_dscp_marking, false)

  if inherit_dscp_marking
    it {
      should contain_file('genius-itm-config.xml').with(
        'ensure'  => 'file',
        'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/genius-itm-config.xml',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content' => /<default-tunnel-tos>inherit<\/default-tunnel-tos>/
      )
    }
  else
    it {
      should contain_file('genius-itm-config.xml').with(
        'ensure'  => 'file',
        'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/genius-itm-config.xml',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content' => /<default-tunnel-tos>0<\/default-tunnel-tos>/
      )
    }
  end
end

# Shared tests that specialize in testing VPP routing node config
def vpp_routing_node_tests(options = {})
  # Extract params
  # NB: This default list should be the same as the one in opendaylight::params
  routing_node = options.fetch(:routing_node, '')

  if routing_node.empty?
    it { should_not contain_file('org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg') }
    it { should_not contain_file_line('routing-node') }
  else
    # Confirm properties of Karaf config file
    # NB: These hashes don't work with Ruby 1.8.7, but we
    #   don't support 1.8.7 so that's okay. See issue #36.
    it {
      should contain_file('org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg',
        'owner'   => 'odl',
        'group'   => 'odl',
      )
    }
    it {
      should contain_file_line('routing-node').with(
        'path'  => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg',
        'line'  => "routing-node=#{routing_node}",
        'match' => '^routing-node=.*$',
      )
    }
  end
end

# ODL username/password tests
def username_password_tests(username, password)

  it {
    should contain_odl_user(username).with(
      :password => password
    )
  }
end

# ODL websocket address tests
def odl_websocket_address_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  odl_bind_ip = options.fetch(:odl_bind_ip, '0.0.0.0')
  # Confirm properties of ODL REST port config file
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.

  if not odl_bind_ip.eql? '0.0.0.0'
    it {
      should contain_file('/opt/opendaylight/etc/org.opendaylight.restconf.cfg').with(
        'ensure'      => 'file',
        'path'        => '/opt/opendaylight/etc/org.opendaylight.restconf.cfg',
        'owner'   => 'odl',
        'group'   => 'odl',
      )
    }
    it {
        should contain_file_line('websocket-address').with(
          'path'    => '/opt/opendaylight/etc/org.opendaylight.restconf.cfg',
          'line'    => "websocket-address=#{odl_bind_ip}",
          'match'   => '^websocket-address=.*$',
      )
    }
  else
    it {
      should_not contain_file_line('websocket-address')
    }
  end
end

def odl_tls_tests(options = {})
  enable_tls = options.fetch(:enable_tls, false)
  tls_keystore_password = options.fetch(:tls_keystore_password, nil)
  tls_trusted_certs = options.fetch(:tls_trusted_certs, [])
  tls_keystore_password = options.fetch(:tls_keystore_password, nil)
  tls_key_file = options.fetch(:tls_key_file, nil)
  tls_cert_file = options.fetch(:tls_cert_file, nil)
  tls_ca_cert_file = options.fetch(:tls_ca_cert_file, nil)
  odl_rest_port = options.fetch(:odl_rest_port, 8181)

  if enable_tls
    if tls_keystore_password.nil?
      it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::PreformattedError) }
      return
    end

    if tls_key_file or tls_cert_file
      if tls_key_file and tls_cert_file
        it {
          should contain_odl_keystore('controller')
        }
      else
        it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::PreformattedError) }
      end
    end
    it {
      should contain_augeas('Remove HTTP ODL REST Port')
      should contain_augeas('ODL SSL REST Port')
      should contain_file_line('set pax TLS port').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'   => "org.osgi.service.http.port.secure = #{odl_rest_port}",
        'match'  => '^#?org.osgi.service.http.port.secure.*$',
      )
      should contain_file_line('set pax TLS keystore location').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'   => 'org.ops4j.pax.web.ssl.keystore = configuration/ssl/ctl.jks',
        'match'  => '^#?org.ops4j.pax.web.ssl.keystore.*$',
      )
      should contain_file_line('set pax TLS keystore integrity password').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'   => "org.ops4j.pax.web.ssl.password = #{tls_keystore_password}",
        'match'  => '^#?org.ops4j.pax.web.ssl.password.*$',
      )
      should contain_file_line('set pax TLS keystore password').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'   => "org.ops4j.pax.web.ssl.keypassword = #{tls_keystore_password}",
        'match'  => '^#?org.ops4j.pax.web.ssl.keypassword.*$',
      )
      should contain_file('aaa-cert-config.xml').with(
        'ensure'  => 'file',
        'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/aaa-cert-config.xml',
        'owner'   => 'odl',
        'group'   => 'odl',
      )
      should contain_file('org.opendaylight.ovsdb.library.cfg').with(
        'ensure'  => 'file',
        'path'    => '/opt/opendaylight/etc/org.opendaylight.ovsdb.library.cfg',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content' =>  /use-ssl = true/
      )
      should contain_file('/opt/opendaylight/configuration/ssl').with(
        'ensure' => 'directory',
        'path'   => '/opt/opendaylight/configuration/ssl',
        'owner'  => 'odl',
        'group'  => 'odl',
        'mode'   => '0755'
      )
      should contain_file_line('enable pax TLS').with(
        'ensure' => 'present',
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'   => 'org.osgi.service.http.secure.enabled = true',
        'match'  => '^#?org.osgi.service.http.secure.enabled.*$',
      )
      should contain_file_line('disable pax HTTP').with(
        'ensure' => 'present',
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'   => 'org.osgi.service.http.enabled = false',
        'match'  => '^#?org.osgi.service.http.enabled.*$',
      )
      should contain_file('org.ops4j.pax.web.cfg').with(
        'ensure' => 'file',
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'owner'  => 'odl',
        'group'  => 'odl',
      )
      should contain_file('default-openflow-connection-config.xml').with(
        'ensure'  => 'file',
        'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/default-openflow-connection-config.xml',
        'owner'   => 'odl',
        'group'   => 'odl',
        'content' =>  /<transport-protocol>TLS<\/transport-protocol>/
      )
    }
  end
end

def stats_polling_enablement_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  stats_polling_enabled = options.fetch(:stats_polling_enabled, false)
  # Confirm properties of ODL REST port config file
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_file('openflowplugin.cfg').with(
      'ensure' => 'file',
      'path'   => '/opt/opendaylight/etc/org.opendaylight.openflowplugin.cfg',
      'owner'  => 'odl',
      'group'  => 'odl',
    )
    should contain_file_line('stats-polling').with(
      'ensure' => 'present',
      'path'   => '/opt/opendaylight/etc/org.opendaylight.openflowplugin.cfg',
      'line'   => "is-statistics-polling-on=#{stats_polling_enabled}",
      'match'  => '^is-statistics-polling-on=.*$',
    )
  }
end
