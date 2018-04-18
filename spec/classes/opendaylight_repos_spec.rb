require 'spec_helper'

describe 'opendaylight::repos' do
  shared_examples_for "opendaylight::repos on Debian" do
    context "with defaults" do
      it { should contain_class('opendaylight::repos') }
      it { should contain_class('apt') }
      it { should contain_apt__ppa('ppa:odl-team/nitrogen') }
    end

    context "with custom deb_repo" do
      let(:params) do
        { :deb_repo => 'ppa:foo/testing' }
      end

      it { should contain_apt__ppa('ppa:foo/testing') }
    end
  end
  shared_examples_for "opendaylight::repos on RedHat" do
    context "with defaults" do
      it { should contain_class('opendaylight::repos') }
      it {
        should contain_yumrepo('opendaylight').with(
          :baseurl  => 'https://nexus.opendaylight.org/content/repositories/opendaylight-fluorine-epel-7-$basearch-devel',
          :enabled  => 1,
          :gpgcheck => 0,
        )
      }
    end

    context "with custom rpm repo options" do
      let(:params) do
        {
          :rpm_repo => 'foo_fake_repo',
          :rpm_repo_enabled => 0,
          :rpm_repo_gpgcheck => 1,
        }
      end
      it {
        should contain_yumrepo('opendaylight').with(
          :baseurl  => 'foo_fake_repo',
          :enabled  => 0,
          :gpgcheck => 1,
        )
      }

    end
  end

  describe "on unsupported os" do
    context "when on Solaris" do
      let(:facts) do
        {:osfamily => 'Solaris', :operatingsystem => 'Solaris'}
      end


      it 'should fail' do
        expect { is_expected.to raise_error(Puppet::Error) }
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) do
        facts
      end

      it_behaves_like "opendaylight::repos on #{facts[:osfamily]}"
    end
  end

end
