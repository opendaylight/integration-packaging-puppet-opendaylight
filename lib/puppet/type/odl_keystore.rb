Puppet::Type.newtype(:odl_keystore) do

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of the keystore"
    newvalues(/^\w+$/)
  end

  newproperty(:ca_file) do
    desc "CA authority certificate file path"
    validate do |value|
      if value
        if !value.is_a?(String)
          raise ArgumentError, "CA cert file path must be a string"
        end
        unless File.file?(value)
          raise ArgumentError, "CA cert file not found: #{value}"
        end
      end
    end
  end

  newproperty(:password) do
    desc "Password for the keystore"
    validate do |value|
      if !value.is_a?(String)
        raise ArgumentError, "Passwords must be a string"
      end

      if value.length < 6
        raise ArgumentError, "Password must be at least 6 characters"
      end
    end

    def change_to_s(current, desire)
      "Keystore Password changed"
    end
  end

  newproperty(:cert_file) do
    desc "Certificate filepath"
    validate do |value|
      if !value.is_a?(String)
        raise ArgumentError, "Certificate file path must be a string"
      end
      unless File.file?(value)
        raise ArgumentError, "Certificate file not found: #{value}"
      end
    end
  end

  newproperty(:key_file) do
    desc "Private key file path"
    validate do |value|
      if !value.is_a?(String)
        raise ArgumentError, "Key file path must be a string"
      end
      unless File.file?(value)
        raise ArgumentError, "Key file not found: #{value}"
      end
    end
  end

  newproperty(:keystore_path) do
    desc "Filepath for the keystore"
    defaultto '/opt/opendaylight/configuration/ssl/ctl.jks'
    validate do |value|
      if !value.is_a?(String)
          raise ArgumentError, "Keystore file path must be a string"
      end
    end
  end
end
