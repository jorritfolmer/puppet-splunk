# vim: ts=2 sw=2 et
class splunk_cluster::inputs ( 
  $inputport = $splunk_cluster::inputport,
  $ciphersuite = $splunk_cluster::ciphersuite,
  $sslversions = $splunk_cluster::sslversions,
  $ecdhcurvename = $splunk_cluster::ecdhcurvename,
  $splunk_home = $splunk_cluster::splunk_home,
){
  if $inputport == undef {
    augeas { '/opt/splunk/etc/system/local/inputs.conf':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/inputs.conf',
      changes => [
        "rm splunktcp-ssl:*",
      ];
    }
  } else {
    augeas { '/opt/splunk/etc/system/local/inputs.conf':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/inputs.conf',
      changes => [
        "set splunktcp-ssl:${inputport}/connection_host ip",
        "set splunktcp-ssl:${inputport}/disabled 0",
        "set SSL/cipherSuite $ciphersuite",
        "set SSL/sslVersions $sslversions",
        "set SSL/serverCert '/opt/splunk/etc/auth/certs/s2s.pem'",
        "set SSL/rootCA '/opt/splunk/etc/auth/certs/ca.crt'",
        "set SSL/dhFile $splunk_home/etc/auth/certs/dhparam.pem",
        "set SSL/ecdhCurveName $ecdhcurvename",
      ];
    }
  }
}

