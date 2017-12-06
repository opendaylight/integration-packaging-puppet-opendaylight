Puppet::Type.type(:odl_keystore).provide(:jks) do
  commands :keytool => 'keytool'

  require 'fileutils'
  require 'openssl'

  def remove_p12_ks
    keystore_dir = File.dirname(@resource[:keystore_path])
    if File.file?("#{keystore_dir}/ctl.p12")
      FileUtils.rm("#{keystore_dir}/ctl.p12")
    end
  end

  def create
    keystore_dir = File.dirname(@resource[:keystore_path])
    unless File.directory?(keystore_dir)
      FileUtils.mkdir_p(keystore_dir, :mode => 0755)
      FileUtils.chown('odl', 'odl', keystore_dir)
    end
    # create p12 keystore
    key = OpenSSL::PKey::RSA.new File.read(@resource[:key_file])
    raw_cert = File.read(@resource[:cert_file])
    certificate = OpenSSL::X509::Certificate.new(raw_cert)
    if @resource[:ca_file]
      p12_ks = OpenSSL::PKCS12.create(@resource[:password], @resource[:name], \
                                      key, certificate, [@resource[:ca_file]])
    else
      p12_ks = OpenSSL::PKCS12.create(@resource[:password], @resource[:name], \
                                      key, certificate)
    end
    open "#{keystore_dir}/ctl1.p12", 'w', 0644 do |io|
      io.write p12_ks.to_der()
    end
    # convert to jks
    keytool('-importkeystore', '-deststorepass', @resource[:password], \
            '-destkeypass', @resource[:password], '-destkeystore', \
            @resource[:keystore_path], '-srckeystore', "#{keystore_dir}/ctl1.p12", \
            '-srcstoretype', 'PKCS12', '-srcstorepass', @resource[:password], \
            '-alias', @resource[:name])
    remove_p12_ks
    unless File.file?(@resource[:keystore_path])
      raise Puppet::Error, 'JKS keystore creation failed'
    end
    FileUtils.chown('odl', 'odl', @resource[:keystore_path])
  end

  def destroy
    FileUtils.rm(@resource[:keystore_path])
  end

  def exists?
    return File.file?(@resource[:keystore_path])
  end

  def key_file
    return @resource[:key_file]
  end

  def key_file=(key_file)
    destroy
    create
  end

  def cert_file
    return @resource[:cert_file]
  end

  def cert_file=(cert_file)
    destroy
    create
  end

  def ca_file
    return @resource[:ca_file]
  end

  def ca_file=(ca_file)
    destroy
    create
  end

  def keystore_path
    if exists?
      return @resource[:keystore_path]
    end
  end

  def keystore_path=(keystore_path)
    destroy
    create
  end

  def password
    begin
      keytool('-list', '-keystore', @resource[:keystore_path], '-storepass', \
              @resource[:password])
      return @resource[:password]
    rescue
      return false
    end
  end

  def password=(password)
    destroy
    create
  end
end
