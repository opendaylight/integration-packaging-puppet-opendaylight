require 'spec_helper'

describe 'opendaylight' do
  # All tests that check OS support/not-support
  describe 'OS support tests' do
    # All tests for OSs in the Red Hat family (CentOS, Fedora)
    describe 'OS family Red Hat ' do
      osfamily = 'RedHat'
      # All tests for Fedora
      describe 'Fedora' do
        operatingsystem = 'Fedora'

        # All tests for supported versions of Fedora
        ['25', '26'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            generic_tests

            # Run tests that specialize in checking rpm-based installs
            # NB: Only testing defaults here, specialized rpm tests elsewhere
            # Note that this function is defined in spec_helper
            rpm_install_tests(operatingsystem: operatingsystem)

            # Run tests that specialize in checking Karaf feature installs
            # NB: Only testing defaults here, specialized Karaf tests elsewhere
            # Note that this function is defined in spec_helper
            karaf_feature_tests

            # Run tests that specialize in checking ODL's REST port config
            # NB: Only testing defaults here, specialized log level tests elsewhere
            # Note that this function is defined in spec_helper
            odl_rest_port_tests

            # Run tests that specialize in checking custom log level config
            # NB: Only testing defaults here, specialized log level tests elsewhere
            # Note that this function is defined in spec_helper
            log_level_tests

            # Run tests that specialize in checking ODL OVSDB HA config
            # NB: Only testing defaults here, specialized enabling HA tests elsewhere
            # Note that this function is defined in spec_helper
            enable_ha_tests

            # Run tests that specialize in checking log file settings
            # NB: Only testing defaults here, specialized log file settings tests elsewhere
            # Note that this function is defined in spec_helper
            log_settings
          end
        end

        # All tests for unsupported versions of Fedora
        ['23'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            expected_msg = "Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}"
            unsupported_os_tests(expected_msg: expected_msg)
          end
        end
      end

      # All tests for CentOS
      describe 'CentOS' do
        operatingsystem = 'CentOS'

        # All tests for supported versions of CentOS
        ['7'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            generic_tests

            # Run test that specialize in checking rpm-based installs
            # NB: Only testing defaults here, specialized rpm tests elsewhere
            # Note that this function is defined in spec_helper
            rpm_install_tests

            # Run test that specialize in checking Karaf feature installs
            # NB: Only testing defaults here, specialized Karaf tests elsewhere
            # Note that this function is defined in spec_helper
            karaf_feature_tests

            # Run tests that specialize in checking ODL's REST port config
            # NB: Only testing defaults here, specialized log level tests elsewhere
            # Note that this function is defined in spec_helper
            odl_rest_port_tests

            # Run test that specialize in checking custom log level config
            # NB: Only testing defaults here, specialized log level tests elsewhere
            # Note that this function is defined in spec_helper
            log_level_tests

            # Run tests that specialize in checking ODL OVSDB HA config
            # NB: Only testing defaults here, specialized enabling HA tests elsewhere
            # Note that this function is defined in spec_helper
            enable_ha_tests

            # Run tests that specialize in checking log file settings
            # NB: Only testing defaults here, specialized log file settings tests elsewhere
            # Note that this function is defined in spec_helper
            log_settings
          end
        end

        # All tests for unsupported versions of CentOS
        ['6'].each do |operatingsystemmajrelease|
          context "#{operatingsystemmajrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemmajrelease => operatingsystemmajrelease,
            }}
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            expected_msg = "Unsupported OS: #{operatingsystem} #{operatingsystemmajrelease}"
            unsupported_os_tests(expected_msg: expected_msg)
          end
        end
      end
    end

    # All tests for OSs in the Debian family (Ubuntu)
    describe 'OS family Debian' do
      osfamily = 'Debian'

      # All tests for Ubuntu 16.04
      describe 'Ubuntu' do
        operatingsystem = 'Ubuntu'

        # All tests for supported versions of Ubuntu
        ['16.04'].each do |operatingsystemrelease|
          context "#{operatingsystemrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemrelease => operatingsystemrelease,
              :lsbdistid => operatingsystem,
              :lsbdistrelease => operatingsystemrelease,
              :lsbdistcodename => 'xenial',
              :puppetversion => '4.9.0',
              :path => ['/usr/local/bin', '/usr/bin', '/bin'],
            }}

            # Run shared tests applicable to all supported OSs
            # Note that this function is defined in spec_helper
            generic_tests

            # Run test that specialize in checking deb-based installs
            # Note that this function is defined in spec_helper
            deb_install_tests

            # Run test that specialize in checking Karaf feature installs
            # NB: Only testing defaults here, specialized Karaf tests elsewhere
            # Note that this function is defined in spec_helper
            karaf_feature_tests

            # Run tests that specialize in checking ODL's REST port config
            # NB: Only testing defaults here, specialized log level tests elsewhere
            # Note that this function is defined in spec_helper
            odl_rest_port_tests

            # Run test that specialize in checking custom log level config
            # NB: Only testing defaults here, specialized log level tests elsewhere
            # Note that this function is defined in spec_helper
            log_level_tests

            # Run tests that specialize in checking ODL OVSDB HA config
            # NB: Only testing defaults here, specialized enabling HA tests elsewhere
            # Note that this function is defined in spec_helper
            enable_ha_tests

            # Run tests that specialize in checking log file settings
            # NB: Only testing defaults here, specialized log file settings tests elsewhere
            # Note that this function is defined in spec_helper
            log_settings
          end
        end

        # All tests for unsupported versions of Ubuntu
        ['12.04', '14.04', '15.10'].each do |operatingsystemrelease|
          context "#{operatingsystemrelease}" do
            let(:facts) {{
              :osfamily => osfamily,
              :operatingsystem => operatingsystem,
              :operatingsystemrelease => operatingsystemrelease,
              :lsbdistid => operatingsystem,
              :lsbdistrelease => operatingsystemrelease,
              :lsbdistcodename => 'xenial',
              :puppetversion => '4.9.0',
            }}
            # Run shared tests applicable to all unsupported OSs
            # Note that this function is defined in spec_helper
            expected_msg = "Unsupported OS: #{operatingsystem} #{operatingsystemrelease}"
            unsupported_os_tests(expected_msg: expected_msg)
          end
        end
      end
    end

    # All tests for unsupported OS families
    ['Suse', 'Solaris'].each do |osfamily|
      context "OS family #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # Run shared tests applicable to all unsupported OSs
        # Note that this function is defined in spec_helper
        expected_msg = "Unsupported OS family: #{osfamily}"
        unsupported_os_tests(expected_msg: expected_msg)
      end
    end
  end

  # All Karaf feature tests
  describe 'Karaf feature tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    describe 'using default features' do
      context 'and not passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{ }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests
      end

      context 'and passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']
        let(:params) {{
          :extra_features => extra_features,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(extra_features: extra_features)
      end
    end

    describe 'overriding default features' do
      default_features = ['standard', 'ssh']
      context 'and not passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{
          :default_features => default_features,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features: default_features)
      end

      context 'and passing extra features' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']
        let(:params) {{
          :default_features => default_features,
          :extra_features => extra_features,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking Karaf feature installs
        # Note that this function is defined in spec_helper
        karaf_feature_tests(default_features: default_features, extra_features: extra_features)
      end
    end
  end

  # All ODL IP/REST port tests
  describe 'IP and REST port tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'using default REST port' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking ODL REST port config
      # Note that this function is defined in spec_helper
      odl_rest_port_tests
    end

    context 'overriding default REST and IP port' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :odl_rest_port => 7777,
        :odl_bind_ip => '127.0.0.1'
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests(odl_bind_ip: '127.0.0.1')

      # Run test that specialize in checking ODL REST port config
      # Note that this function is defined in spec_helper
      odl_rest_port_tests(odl_rest_port: 7777, odl_bind_ip: '127.0.0.1')
    end
  end

  # All custom log level tests
  describe 'custom log level tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'using default log levels' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking custom log level config
      # Note that this function is defined in spec_helper
      log_level_tests
    end

    context 'adding one custom log level' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      custom_log_levels = { 'org.opendaylight.ovsdb' => 'TRACE' }

      let(:params) {{
        :log_levels => custom_log_levels,
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking log level config
      # Note that this function is defined in spec_helper
      log_level_tests(log_levels: custom_log_levels)
    end

    context 'adding two custom log levels' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      custom_log_levels = { 'org.opendaylight.ovsdb' => 'TRACE',
                         'org.opendaylight.ovsdb.lib' => 'INFO' }

      let(:params) {{
        :log_levels => custom_log_levels,
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking log level config
      # Note that this function is defined in spec_helper
      log_level_tests(log_levels: custom_log_levels)
    end
  end

  describe 'log mechanism settings' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'

    # All custom log file size and rollover tests
    context 'log to file using default size and rollover' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test specific to log settings
      log_settings
    end

    context 'log to file customizing size' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :log_max_size => '1GB',
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test specific to log settings
      log_settings(log_max_size: '1GB')
    end

    context 'log to file customizing rollover' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :log_max_rollover => 3,
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test specific to log settings
      log_settings(log_max_rollover: 3)
    end

    context 'log to file customizing size and rollover' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :log_max_size => '1GB',
        :log_max_rollover => 3,
        :log_rollover_fileindex => 'min'
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test specific to log settings
      log_settings(log_max_size: '1GB',
                   log_max_rollover: 3,
                   log_rollover_fileindex: 'min')
    end

    context 'log to console' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :log_mechanism => 'console',
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test specific to log settings
      log_settings(log_mechanism: 'console')
    end
  end

  # All OVSDB HA enable/disable tests
  describe 'OVSDB HA enable/disable tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'using enable_ha default' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking ODL OVSDB HA config
      # Note that this function is defined in spec_helper
      enable_ha_tests
    end

    context 'using false for enable_ha' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :enable_ha => false,
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking ODL OVSDB HA config
      # Note that this function is defined in spec_helper
      enable_ha_tests(enable_ha: false)
    end

    context 'using true for enable_ha' do
      context 'using ha_node_count >=2' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{
          :enable_ha => true,
          :ha_node_ips => ['0.0.0.0', '127.0.0.1']
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking ODL OVSDB HA config
        # Note that this function is defined in spec_helper
        enable_ha_tests(enable_ha: true, ha_node_ips: ['0.0.0.0', '127.0.0.1'])
      end

      context 'using custom modules for sharding' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{
          :enable_ha => true,
          :ha_node_ips => ['0.0.0.0', '127.0.0.1'],
          :ha_db_modules => {'default' => false, 'topology' => 'urn:opendaylight:topology'}
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking ODL OVSDB HA config
        # Note that this function is defined in spec_helper
        enable_ha_tests(enable_ha: true, ha_node_ips: ['0.0.0.0', '127.0.0.1'])
      end
    end
  end


  # All install method tests
  describe 'install method tests' do

    # All tests for RPM install method
    describe 'RPM' do
      # Non-OS-type tests assume CentOS 7
      #   See issue #43 for reasoning:
      #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
      osfamily = 'RedHat'
      operatingsystem = 'CentOS'
      operatingsystemrelease = '7.0'
      operatingsystemmajrelease = '7'

      context 'installing from default repo' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking RPM-based installs
        # Note that this function is defined in spec_helper
        rpm_install_tests
      end

      context 'installing from Nexus repo' do
        rpm_repo = 'https://nexus.opendaylight.org/content/repositories/opendaylight-oxygen-epel-7-$basearch-devel'
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => operatingsystemmajrelease,
        }}

        let(:params) {{
          :rpm_repo => rpm_repo,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking RPM-based installs
        # Note that this function is defined in spec_helper
        rpm_install_tests(rpm_repo: rpm_repo)
      end
    end

    # All tests for Deb install method
    describe 'Deb' do
      osfamily = 'Debian'
      operatingsystem = 'Ubuntu'
      operatingsystemrelease = '16.04'
      operatingsystemmajrelease = '16'
      lsbdistcodename = 'xenial'

      context 'installing Deb' do
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemrelease => operatingsystemrelease,
          :operatingsystemmajrelease => operatingsystemmajrelease,
          :lsbdistid => operatingsystem,
          :lsbdistrelease => operatingsystemrelease,
          :lsbmajdistrelease => operatingsystemmajrelease,
          :lsbdistcodename => lsbdistcodename,
          :puppetversion => Puppet.version,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking RPM-based installs
        # Note that this function is defined in spec_helper
        deb_install_tests
      end

      context 'installing Oxygen Deb' do
        deb_repo = 'ppa:odl-team/oxygen'
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemrelease => operatingsystemrelease,
          :operatingsystemmajrelease => operatingsystemmajrelease,
          :lsbdistid => operatingsystem,
          :lsbdistrelease => operatingsystemrelease,
          :lsbmajdistrelease => operatingsystemmajrelease,
          :lsbdistcodename => lsbdistcodename,
          :puppetversion => Puppet.version,
        }}

        let(:params) {{
          :deb_repo => deb_repo,
        }}

        # Run shared tests applicable to all supported OSs
        # Note that this function is defined in spec_helper
        generic_tests

        # Run test that specialize in checking RPM-based installs
        # Note that this function is defined in spec_helper
        deb_install_tests(deb_repo: deb_repo)
      end
    end
  end

  # SNAT Mechanism tests
  describe 'SNAT mechanism tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'using controller' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :extra_features => ['odl-netvirt-openstack'],
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking security groups
      # Note that this function is defined in spec_helper
      snat_mechanism_tests
    end

    context 'using conntrack' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :snat_mechanism => 'conntrack',
        :extra_features => ['odl-netvirt-openstack'],
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking security groups
      # Note that this function is defined in spec_helper
      snat_mechanism_tests('conntrack')
    end
  end

  # SFC tests
  describe 'SFC tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'not using odl-netvirt-sfc feature' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking security groups
      # Note that this function is defined in spec_helper
      sfc_tests
    end

    context 'using odl-netvirt-sfc feature' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :extra_features => ['odl-netvirt-sfc'],
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking security groups
      # Note that this function is defined in spec_helper
      sfc_tests(extra_features: ['odl-netvirt-sfc'])
    end
  end

  # DSCP marking tests
  describe 'DSCP marking tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'use default value' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking security groups
      # Note that this function is defined in spec_helper
      dscp_tests
    end

    context 'inherit DSCP values' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :inherit_dscp_marking => :true,
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking security groups
      # Note that this function is defined in spec_helper
      dscp_tests(inherit_dscp_marking: true)
    end
  end

  # VPP routing node config tests
  describe 'VPP routing node tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'using default - no routing node' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking routing-node config
      # Note that this function is defined in spec_helper
      vpp_routing_node_tests
    end

    context 'using node name for routing node' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :vpp_routing_node => 'test-node-1',
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking routing-node config
      # Note that this function is defined in spec_helper
      vpp_routing_node_tests(routing_node: 'test-node-1')
    end
  end

  # ODL username/password tests
  describe 'ODL username/password tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'using default username/password' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking username/password config
      # Note that this function is defined in spec_helper
      username_password_tests('admin','admin')
    end

    context 'specifying non-default username/password' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :username => 'test',
        :password => 'test'
      }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking routing-node config
      # Note that this function is defined in spec_helper
      username_password_tests('test', 'test')
    end
  end

  # websocket address tests
  describe 'ODL websocket address tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'using default websocket address' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking websocket address
      # Note that this function is defined in spec_helper
      odl_websocket_address_tests
    end

    context 'overriding websocket address' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
       :odl_bind_ip => '127.0.0.1'
       }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests(odl_bind_ip: '127.0.0.1')

      # Run test that specialize in checking websocket address
      # Note that this function is defined in spec_helper
      odl_websocket_address_tests(odl_bind_ip: '127.0.0.1')
    end
  end

  # TLS tests
  describe 'ODL TLS tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'
    context 'enabling TLS without required keystore password (negative test)' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
       :enable_tls => :true
       }}

      # Run test that specialize in checking TLS
      # Note that this function is defined in spec_helper
      odl_tls_tests(enable_tls:true)
    end
    context 'enabling TLS with required params' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
       :enable_tls => true,
       :tls_keystore_password => '123456',
       }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test that specialize in checking TLS
      # Note that this function is defined in spec_helper
      odl_tls_tests(enable_tls:true, tls_keystore_password:'123456')
    end
  end

  describe 'polling enablement settings' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'

    # Default statistics polling off
    context 'do not poll ovs statistics' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{ }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test specific to log settings
      stats_polling_enablement_tests
    end

    # Default statistics polling on
    context 'poll ovs statistics' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
       :stats_polling_enabled => true,
       }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests

      # Run test specific to log settings
      stats_polling_enablement_tests(stats_polling_enabled:true)
    end
  end

  describe 'Different IPv support tests' do
    # Non-OS-type tests assume CentOS 7
    #   See issue #43 for reasoning:
    #   https://github.com/dfarrell07/puppet-opendaylight/issues/43#issue-57343159
    osfamily = 'RedHat'
    operatingsystem = 'CentOS'
    operatingsystemmajrelease = '7'

    context 'IPv6 deployment' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :odl_bind_ip => '::1'
        }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests(odl_bind_ip:'::1')
    end

    context 'IPv4 deployment' do
      let(:facts) {{
        :osfamily => osfamily,
        :operatingsystem => operatingsystem,
        :operatingsystemmajrelease => operatingsystemmajrelease,
      }}

      let(:params) {{
        :odl_bind_ip => '127.0.0.1'
        }}

      # Run shared tests applicable to all supported OSs
      # Note that this function is defined in spec_helper
      generic_tests(odl_bind_ip:'127.0.0.1')
    end
  end
end
