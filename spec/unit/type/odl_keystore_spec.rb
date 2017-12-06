require 'puppet'
require 'puppet/type/odl_keystore'
require 'spec_helper'

describe 'Puppet::Type.type(:odl_keystore)' do

  it 'should accept name, password, tls options' do
    File.stubs(:file?).returns(true)
    Puppet::Type.type(:odl_keystore).new(
      :name      => 'admin',
      :password  => 'admin12345',
      :cert_file => '/tmp/dummy.txt',
      :key_file  => '/tmp/dummy.txt',
      :ca_file   => '/tmp/dummy.txt')
  end

  it 'should fail with password less than 6 chars' do
    File.stubs(:file?).returns(true)
    expect{Puppet::Type.type(:odl_keystore).new(
      :name      => 'admin',
      :password  => 'admin',
      :cert_file => '/tmp/dummy.txt',
      :key_file  => '/tmp/dummy.txt',
      :ca_file   => '/tmp/dummy.txt')}.to raise_error(Puppet::ResourceError)
  end
end
