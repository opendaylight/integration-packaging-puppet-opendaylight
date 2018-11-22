require 'spec_helper_acceptance'

# NB: There are a large number of helper functions used in these tests.
# They make this code much more friendly, but may need to be referenced.
#   The serverspec helpers (`should`, `be_running`...) are documented here:
#     http://serverspec.org/resource_types.html
#   Custom helpers (`install_odl`, `*_validations`) are in:
#     <this module>/spec/spec_helper_acceptance.rb

describe 'opendaylight class' do
  describe 'testing install methods' do
    # Call specialized helper fn to install OpenDaylight
    install_odl

    # Run checks specific to install type, via env var passed from Rakefile
    if :osfamily == 'RedHat'
      # Call specialized helper fn for RPM-type install validations
      rpm_validations
    elsif :osfamily == 'Debian'
      # Call specialized helper fn for Deb-type install validations
      deb_validations
    end

    # Use helper fn to run generic validations
    generic_validations
  end

  describe 'testing Karaf config file' do
    describe 'using default features' do
      context 'and not passing extra features' do
        # Call specialized helper fn to install OpenDaylight
        install_odl

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations
      end

      context 'and passing extra features' do
        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']

        # Call specialized helper fn to install OpenDaylight
        install_odl(extra_features: extra_features)

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations(extra_features: extra_features)
      end
    end

    describe 'overriding default features' do
      # These are real but arbitrarily chosen features
      default_features = ['standard', 'ssh']

      context 'and not passing extra features' do
        # Call specialized helper fn to install OpenDaylight
        install_odl(default_features: default_features)

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations(default_features: default_features)
      end

      context 'and passing extra features' do
        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']

        # Call specialized helper fn to install OpenDaylight
        install_odl(default_features: default_features,
                    extra_features: extra_features)

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations(default_features: default_features,
                                 extra_features: extra_features)
      end
    end
  end

  describe 'logging mechanism' do
    context 'log to file using default size and rollover' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for log settings validations
      log_settings_validations
    end

    context 'log to file customising size' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(log_max_size: '1GB')

      # Call specialized helper fn for log settings validations
      log_settings_validations(log_max_size: '1GB')
    end

    context 'log to file customising rollover' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(log_max_rollover: 3)

      # Call specialized helper fn for log settings validations
      log_settings_validations(log_max_rollover: 3)
    end

    context 'log to file customising size and rollover' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(log_max_size: '1GB',
                  log_max_rollover: 3,
                  log_rollover_fileIndex: 'min')

      # Call specialized helper fn for log settings validations
      log_settings_validations(log_max_size: '1GB',
                               log_max_rollover: 3,
                               log_rollover_fileIndex: 'min')
    end

    context 'log to file customizing pattern' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(log_pattern: '%d{ISO8601} | %-5p | %-16t | %m%n')

      # Call specialized helper fn for log settings validations
      log_settings_validations(log_pattern: '%d{ISO8601} | %-5p | %-16t | %m%n')
    end

    context 'log to console' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(log_mechanism: 'console')

      # Call specialized helper fn for log settings validations
      log_settings_validations(log_mechanism: 'console')
    end

    context 'log to console customizing pattern' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(log_mechanism: 'console',
                  log_pattern: '%d{ISO8601} | %-5p | %-16t | %m%n')

      # Call specialized helper fn for log settings validations
      log_settings_validations(log_mechanism: 'console',
                               log_pattern: '%d{ISO8601} | %-5p | %-16t | %m%n')
    end
  end

  describe 'testing REST port config file' do
    context 'using default port' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for REST port config validations
      port_config_validations
    end

    context 'overriding default port' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(odl_rest_port: 7777)

      # Call specialized helper fn for REST port config validations
      port_config_validations(odl_rest_port: 7777)
    end
  end

  describe 'testing binding ODL to an IP' do
    install_odl(odl_bind_ip: '127.0.0.1')
    context 'using specific IP for ODL' do
      odl_bind_ip_validation(odl_bind_ip: '127.0.0.1')
    end
  end

  describe 'testing custom logging verbosity' do
    context 'using default log levels' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for custom logger verbosity validations
      log_level_validations
    end

    context 'adding one custom log level' do
      custom_log_levels = { 'org.opendaylight.ovsdb' => 'TRACE' }

      # Call specialized helper fn to install OpenDaylight
      install_odl(log_levels: custom_log_levels)

      # Call specialized helper fn for custom logger verbosity validations
      log_level_validations(log_levels: custom_log_levels)
    end

    context 'adding two custom log level' do
      custom_log_levels = { 'org.opendaylight.ovsdb' => 'TRACE',
                            'org.opendaylight.ovsdb.lib' => 'INFO' }

      # Call specialized helper fn to install OpenDaylight
      install_odl(log_levels: custom_log_levels)

      # Call specialized helper fn for custom logger verbosity validations
      log_level_validations(log_levels: custom_log_levels)
    end
  end

  describe 'testing odl username/password' do
    bind_ip = '127.0.0.1'
    context 'using default username/password' do
    context 'using non-default bind ip' do
      # Call specialized helper fn to install OpenDaylight
      install_odl({:odl_bind_ip => bind_ip, :extra_features => ['odl-restconf']})

      # Call specialized helper fn for username/password validations
      #username_password_validations
    end
    end
  end

  describe 'testing odl HA configuration' do
    bind_ip = '127.0.0.1'
    odl_ips = ['127.0.0.1', '127.0.0.2', '127.0.0.3']
    context 'using default modules' do
      install_odl(odl_bind_ip: bind_ip, enable_ha: true, ha_node_ips: odl_ips)

      enable_ha_validations(odl_bind_ip: bind_ip, enable_ha: true,
                            ha_node_ips: odl_ips)
    end

    context 'specifying datastore modules' do
      db_modules = {
        'default' => false,
        'topology' => 'urn:opendaylight:topology'
      }
      install_odl(odl_bind_ip: bind_ip, enable_ha: true, ha_node_ips: odl_ips,
                  ha_db_modules: db_modules)
      enable_ha_validations(odl_bind_ip: bind_ip, enable_ha: true,
                            ha_node_ips: odl_ips, ha_db_modules: db_modules)
    end
  end

  describe 'testing configuring SNAT' do
    context 'using default SNAT mechanism' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(extra_features: ['odl-netvirt-openstack'])

      # Call specialized helper fn for SNAT config validations
      snat_mechanism_validations
    end

    context 'using conntrack SNAT' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(extra_features: ['odl-netvirt-openstack'], snat_mechanism: 'conntrack')

      # Call specialized helper fn for SNAT mechanism validations
      snat_mechanism_validations(snat_mechanism: 'conntrack')
    end
  end

  describe 'testing configuring SFC' do
    context 'not using SFC feature' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for SFC config validations
      sfc_validations
    end

    context 'using SFC feature' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(extra_features: ['odl-netvirt-sfc'])

      # Call specialized helper fn for SFC config validations
      sfc_validations(extra_features: ['odl-netvirt-sfc'])
    end
  end

  describe 'testing configuring tos value for DSCP marking' do
    context 'not enabling DSCP marking' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for SFC config validations
      dscp_validations
    end

    context 'enabling DSCP marking' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(inherit_dscp_marking: true)

      # Call specialized helper fn for SFC config validations
      dscp_validations(inherit_dscp_marking: true)
    end
  end

  describe 'testing websocket address config' do
    context 'using default ip' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for websocket address config validations
      websocket_address_validations
    end

    context 'overriding default ip' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(odl_bind_ip: '127.0.0.1')

      # Call specialized helper fn for websocket address config validations
      websocket_address_validations(odl_bind_ip: '127.0.0.1')
    end
  end

  describe 'testing enabling TLS' do
    context 'with self-signed key/cert creation' do
      install_odl(enable_tls: true, tls_keystore_password: '123456')

      # Call specialized helper fn for TLS config validations
      tls_validations(enable_tls: true, tls_keystore_password: '123456')
    end
  end

  describe 'testing stats polling enablement' do
    context 'with polling enabled' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(stats_polling_enabled: true)

      # Call specialized helper fn for polling enablement validations
      stats_polling_validations(stats_polling_enabled: true)
    end

    context 'with polling disabled' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for polling enablement validations
      stats_polling_validations
    end
  end

  describe 'testing different IPv deployments' do
    context 'IPv6 support tests' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(odl_bind_ip: '::1')

      # Call specialized helper fn for polling enablement validations
      generic_validations(odl_bind_ip: '::1')
    end

    context 'IPv4 support test' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(odl_bind_ip: '127.0.0.1')

      # Call specialized helper fn for polling enablement validations
      generic_validations(odl_bind_ip: '127.0.0.1')
    end
  end

  describe 'testing passing extra java option' do
    context 'pass java heap size' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(java_opts: '-Xmx8192m')

      # Call specialized helper fn for polling enablement validations
      generic_validations(java_opts: '-Xmx8192m')
    end
  end

  describe 'testing configuring inactivity probe' do
    context 'with specifying inactivity probe timer' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(inactivity_probe: 99999)

      # Call specialized helper fn for probe validations
      inactivity_probe_validations(inactivity_probe: 99999)
    end
  end
end
