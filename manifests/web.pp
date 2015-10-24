# vim: ts=2 sw=2 et
class splunk_cluster::web ( 
  $ciphersuite = $splunk_cluster::ciphersuite,
  $sslversions = $splunk_cluster::sslversions,
  $httpport = $splunk_cluster::httpport,
  $ecdhcurvename = $splunk_cluster::ecdhcurvename,
){
  if $httpport == undef {
    augeas { '/opt/splunk/etc/system/local/web.conf':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/web.conf',
      changes => [
        "rm settings/httpport",
        "set settings/startwebserver 0",
        "rm settings/enableSplunkWebSSL",
        "rm settings/sslVersions",
        "rm settings/cipherSuite",
        "rm settings/ecdhCurveName",
      ];
    }
  } else {
    augeas { '/opt/splunk/etc/system/local/web.conf':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/web.conf',
      changes => [
        "set settings/httpport $httpport",
        "set settings/startwebserver 1",
        "set settings/enableSplunkWebSSL true",
        "set settings/sslVersions $sslversions",
        "set settings/cipherSuite $ciphersuite",
        "set settings/ecdhCurveName $ecdhcurvename",
        "set settings/dhFile $splunk_home/etc/auth/certs/dhparam.pem",
      ];
    }
  }
}
