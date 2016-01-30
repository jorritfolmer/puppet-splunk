# vim: ts=2 sw=2 et

class splunk::server::ssl (
  $ciphersuite = $splunk::ciphersuite,
  $sslversions = $splunk::sslversions,
  $ecdhcurvename = $splunk::ecdhcurvename,
  $splunk_home = $splunk::splunk_home
){
  if $ecdhcurvename == undef {
    augeas { "${splunk_home}/etc/system/local/server.conf/sslConfig":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/server.conf",
      changes => [
        'set sslConfig/enableSplunkdSSL true',
        "set sslConfig/cipherSuite ${ciphersuite}",
        "set sslConfig/sslVersions ${sslversions}",
        "set sslConfig/dhFile ${splunk_home}/etc/auth/certs/dhparam.pem",
        'rm sslConfig/ecdhCurveName',
      ],
    }
  } else {
    augeas { "${splunk_home}/etc/system/local/server.conf/sslConfig":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/server.conf",
      changes => [
        'set sslConfig/enableSplunkdSSL true',
        "set sslConfig/cipherSuite ${ciphersuite}",
        "set sslConfig/sslVersions ${sslversions}",
        "set sslConfig/dhFile ${splunk_home}/etc/auth/certs/dhparam.pem",
        "set sslConfig/ecdhCurveName ${ecdhcurvename}",
      ],
    }
  }
}

