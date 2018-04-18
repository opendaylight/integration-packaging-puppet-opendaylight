require 'puppet'
require 'puppet/provider/odl_keystore/jks'
require 'spec_helper'
require 'fileutils'

provider_class = Puppet::Type.type(:odl_keystore).provider(:jks)

describe 'Puppet::Type.type(:odl_keystore).provider(:jks)' do

  let :odl_attrs do
    {
      :name      => 'controller',
      :ensure    => 'present',
      :password  => 'dummypassword'
    }
  end

  let :resource do
    Puppet::Type::Odl_keystore.new(odl_attrs)
  end

  let :provider do
    provider_class.new(resource)
  end

  describe "when changing cert_file" do
    it 'should recreate keystore' do
      File.stubs(:file?).returns(true)
      provider.expects(:destroy)
      provider.expects(:create)
      provider.cert_file = '/tmp/blah.pem'
    end
  end

  describe "when changing key_file" do
    it 'should recreate keystore' do
      File.stubs(:file?).returns(true)
      provider.expects(:destroy)
      provider.expects(:create)
      provider.key_file = '/tmp/blah.pem'
    end
  end

  describe "when adding a CA cert" do
    it 'should recreate keystore' do
      provider.expects(:destroy)
      provider.expects(:create)
      provider.ca_file = '/tmp/blah.pem'
    end
  end

  describe "when keystore path" do
    it 'should recreate keystore' do
      provider.expects(:destroy)
      provider.expects(:create)
      provider.keystore_path = '/tmp/blah.jks'
    end
  end

  describe "when changing password" do
    it 'should change password' do
      provider.expects(:destroy)
      provider.expects(:create)
      provider.password = 'admin123'
    end
  end
end
