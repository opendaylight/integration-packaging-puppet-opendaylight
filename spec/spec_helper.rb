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
def generic_tests()
  # Confirm that module compiles
  it { should compile }
  it { should compile.with_all_deps }

  # Confirm presence of classes
  it { should contain_class('opendaylight') }
  it { should contain_class('opendaylight::params') }
  it { should contain_class('opendaylight::install') }
  it { should contain_class('opendaylight::config') }
  it { should contain_class('opendaylight::service') }

  # Confirm relationships between classes
  it { should contain_class('opendaylight::install').that_comes_before('Class[opendaylight::config]') }
  it { should contain_class('opendaylight::config').that_requires('Class[opendaylight::install]') }
  it { should contain_class('opendaylight::config').that_notifies('Class[opendaylight::service]') }
  it { should contain_class('opendaylight::service').that_subscribes_to('Class[opendaylight::config]') }
  it { should contain_class('opendaylight::service').that_comes_before('Class[opendaylight]') }
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
end

# Shared tests that specialize in testing log file size and rollover
def log_settings(options = {})
  # Extraxt params. The dafault value should be same as in opendaylight::params
  log_max_size = options.fetch(:log_max_size, '10GB')
  log_max_rollover = options.fetch(:log_max_rollover, 2)
  log_mechanism = options.fetch(:log_mechanism, 'file')

  if log_mechanism == 'console'
    it {
      should contain_file_line('rootlogger').with(
        'path'  => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'  => 'log4j.rootLogger=INFO, stdout, osgi:*',
        'match' => '^log4j.rootLogger.*$',
      )
    }
    it {
      should contain_file_line('logappender').with(
        'path'               => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'               => 'log4j.appender.stdout.direct=true',
        'after'              => 'log4j.appender.stdout=org.apache.log4j.ConsoleAppender',
        'match'              => '^log4j.appender.stdout.direct.*$',
        'append_on_no_match' => true
      )
    }
  else
    it {
      should contain_file_line('logmaxsize').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'   => "log4j.appender.out.maxFileSize=#{log_max_size}",
        'match'  => '^log4j.appender.out.maxFileSize.*$',
      )
    }
    it {
      should contain_file_line('logmaxrollover').with(
        'path'   => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
        'line'   => "log4j.appender.out.maxBackupIndex=#{log_max_rollover}",
        'match'  => '^log4j.appender.out.maxBackupIndex.*$',
      )
    }
  end
end

# Shared tests that specialize in testing Karaf feature installs
def karaf_feature_tests(options = {})
  # Extract params
  # NB: This default list should be the same as the one in opendaylight::params
  # TODO: Remove this possible source of bugs^^
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
  # TODO: Remove this possible source of bugs^^
  odl_rest_port = options.fetch(:odl_rest_port, 8080)
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
      should contain_file_line('org.ops4j.pax.web.cfg').with(
        'path'  => '/opt/opendaylight/etc/org.ops4j.pax.web.cfg',
        'line'  => "org.ops4j.pax.web.listening.addresses = #{odl_bind_ip}",
      )
    }
  else
    it {
      should_not contain_augeas('ODL REST IP')
    }
  end
end

def log_level_tests(options = {})
  # Extract params
  # NB: This default value should be the same as one in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  log_levels = options.fetch(:log_levels, {})

  if log_levels.empty?
    # Should contain log level config file
    it {
      should_not contain_file_line('logger-org.opendaylight.ovsdb')
    }
  else
    # Verify each custom log level config entry
    log_levels.each_pair do |logger, level|
      it {
        should contain_file_line("logger-#{logger}").with(
          'ensure' => 'present',
          'path' => '/opt/opendaylight/etc/org.ops4j.pax.logging.cfg',
          'line' => "log4j.logger.#{logger}=#{level}",
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
  rpm_repo = options.fetch(:rpm_repo, 'opendaylight-7-testing')
  java_opts = options.fetch(:java_opts, '-Djava.net.preferIPv4Stack=true')

  # Default to CentOS 7 Yum repo URL

  # Confirm presence of RPM-related resources
  it { should contain_yumrepo(rpm_repo) }
  it { should contain_package('opendaylight') }

  # Confirm relationships between RPM-related resources
  it { should contain_package('opendaylight').that_requires("Yumrepo[#{rpm_repo}]") }
  it { should contain_yumrepo(rpm_repo).that_comes_before('Package[opendaylight]') }

  # Confirm properties of RPM-related resources
  # NB: These hashes don't work with Ruby 1.8.7, but we
  #   don't support 1.8.7 so that's okay. See issue #36.
  it {
    should contain_yumrepo(rpm_repo).with(
      'enabled'     => '1',
      'gpgcheck'    => '0',
      'descr'       => 'OpenDaylight SDN Controller',
      'baseurl'     => "http://cbs.centos.org/repos/nfv7-#{rpm_repo}/$basearch/os/",
    )
  }
  it {
    should contain_package('opendaylight').with(
      'ensure'   => 'present',
    )
  }

  it {
    should contain_file_line('java_options_systemd').with(
      'ensure' => 'present',
      'path' => '/usr/lib/systemd/system/opendaylight.service',
      'line' => "Environment=_JAVA_OPTIONS=\'#{java_opts}\'",
      'after' => 'ExecStart=/opt/opendaylight/bin/start',
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
  rpm_repo = options.fetch(:rpm_repo, 'opendaylight-7-testing')

  # Confirm that classes fail on unsupported OSs
  it { expect { should contain_class('opendaylight') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::install') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::config') }.to raise_error(Puppet::Error, /#{expected_msg}/) }
  it { expect { should contain_class('opendaylight::service') }.to raise_error(Puppet::Error, /#{expected_msg}/) }

  # Confirm that other resources fail on unsupported OSs
  it { expect { should contain_yumrepo(rpm_repo) }.to raise_error(Puppet::Error, /#{expected_msg}/) }
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
def sfc_tests()
  it { should contain_file('/opt/opendaylight/etc/opendaylight') }
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore')}
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore/initial')}
  it { should contain_file('/opt/opendaylight/etc/opendaylight/datastore/initial/config')}

  it {
    should contain_file('netvirt-elanmanager-config.xml').with(
      'ensure'  => 'file',
      'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/netvirt-elanmanager-config.xml',
      'owner'   => 'odl',
      'group'   => 'odl',
      'source'  => 'puppet:///modules/opendaylight/netvirt-elanmanager-config.xml'
      )
    should contain_file('genius-itm-config.xml').with(
      'ensure'  => 'file',
      'path'    => '/opt/opendaylight/etc/opendaylight/datastore/initial/config/genius-itm-config.xml',
      'owner'   => 'odl',
      'group'   => 'odl',
      'source'  => 'puppet:///modules/opendaylight/genius-itm-config.xml'
      )
    }
end

# Shared tests that specialize in testing VPP routing node config
def vpp_routing_node_tests(options = {})
  # Extract params
  # NB: This default list should be the same as the one in opendaylight::params
  # TODO: Remove this possible source of bugs^^
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
  # TODO: Remove this possible source of bugs^^
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
