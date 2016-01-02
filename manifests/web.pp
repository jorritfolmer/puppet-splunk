# vim: ts=2 sw=2 et
class splunk::web (
  $ciphersuite = $splunk::ciphersuite,
  $sslversions = $splunk::sslversions,
  $httpport = $splunk::httpport,
  $ecdhcurvename = $splunk::ecdhcurvename,
  $splunk_home = $splunk::splunk_home
){
  if $httpport == undef {
    augeas { "${splunk_home}/etc/system/local/web.conf":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/web.conf",
      changes => [
        'rm settings/httpport',
        'set settings/startwebserver 0',
        'rm settings/enableSplunkWebSSL',
        'rm settings/sslVersions',
        'rm settings/cipherSuite',
        'rm settings/ecdhCurveName',
      ];
    }
  } else {
    if $ecdhcurvename == undef {
      augeas { "${splunk_home}/etc/system/local/web.conf":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "${splunk_home}/etc/system/local/web.conf",
        changes => [
          "set settings/httpport ${httpport}",
          'set settings/startwebserver 1',
          'set settings/enableSplunkWebSSL true',
          "set settings/sslVersions ${sslversions}",
          "set settings/cipherSuite ${ciphersuite}",
          'rm settings/ecdhCurveName',
        ];
      }
    } else {
      augeas { "${splunk_home}/etc/system/local/web.conf":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "${splunk_home}/etc/system/local/web.conf",
        changes => [
          "set settings/httpport ${httpport}",
          'set settings/startwebserver 1',
          'set settings/enableSplunkWebSSL true',
          "set settings/sslVersions ${sslversions}",
          "set settings/cipherSuite ${ciphersuite}",
          "set settings/ecdhCurveName ${ecdhcurvename}",
        ];
      }
    }
  }
}
