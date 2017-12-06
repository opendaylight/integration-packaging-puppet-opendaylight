# == Class opendaylight::post_config
#
# This class handles ODL config changes after ODL has come up.
# These configuration changes do not require restart of ODL.
# It's called from the opendaylight class.
#
class opendaylight::post_config {
  # Add trusted certs to ODL keystore
  $curl_post = "curl -k -X POST -o /dev/null --fail --silent -H 'Content-Type: application/json' -H 'Cache-Control: no-cache'"
  $cert_rest_url = "https://${opendaylight::odl_bind_ip}:${opendaylight::odl_rest_port}/restconf/operations/aaa-cert-rpc:setNodeCertifcate"
  if $opendaylight::enable_tls {
    if !empty($opendaylight::tls_trusted_certs) {
      $opendaylight::tls_trusted_certs.each |$idx, $cert| {
        $cert_data = convert_cert_to_string($cert)
        $rest_data = @("END":json/L)
          {\
            "aaa-cert-rpc:input": {\
            "aaa-cert-rpc:node-alias": "node${idx}",\
            "aaa-cert-rpc:node-cert": "${cert_data}"\
            }\
          }
          |-END

        exec { "Add trusted cert: ${cert}":
          command   => "${curl_post} -u ${opendaylight::username}:${
            opendaylight::password} -d '${rest_data}' ${cert_rest_url}",
          tries     => 5,
          try_sleep => 30,
          path      => '/usr/sbin:/usr/bin:/sbin:/bin',
        }
      }
    }
  }
}
