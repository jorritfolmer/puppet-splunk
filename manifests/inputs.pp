# vim: ts=2 sw=2 et
class splunk::inputs ( 
  $inputport = $splunk::inputport,
  $ciphersuite = $splunk::ciphersuite,
  $sslversions = $splunk::sslversions,
  $ecdhcurvename = $splunk::ecdhcurvename,
  $splunk_home = $splunk::splunk_home,
){
  if $inputport == undef {
    augeas { "$splunk_home/etc/system/local/inputs.conf":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "$splunk_home/etc/system/local/inputs.ronf",
      changes => [
        "rm splunktcp-ssl:*",
      ];
    }
  } else {
    if $ecdhcurvename == undef {
      augeas { "$splunk_home/etc/system/local/inputs.conf":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "$splunk_home/etc/system/local/inputs.conf",
        changes => [
          "set splunktcp-ssl:${inputport}/connection_host ip",
          "set splunktcp-ssl:${inputport}/disabled 0",
          "set SSL/cipherSuite $ciphersuite",
          "set SSL/sslVersions $sslversions",
          "set SSL/serverCert '$splunk_home/etc/auth/certs/s2s.pem'",
          "set SSL/rootCA '$splunk_home/etc/auth/certs/ca.crt'",
          "set SSL/dhfile '$splunk_home/etc/auth/certs/dhparam.pem'",
          "set SSL/ecdhCurveName $ecdhcurvename",
        ];
      }
    } else {
      augeas { "$splunk_home/etc/system/local/inputs.conf":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "$splunk_home/etc/system/local/inputs.conf",
        changes => [
          "set splunktcp-ssl:${inputport}/connection_host ip",
          "set splunktcp-ssl:${inputport}/disabled 0",
          "set SSL/cipherSuite $ciphersuite",
          "set SSL/sslVersions $sslversions",
          "set SSL/serverCert '$splunk_home/etc/auth/certs/s2s.pem'",
          "set SSL/rootCA '$splunk_home/etc/auth/certs/ca.crt'",
          "set SSL/dhfile '$splunk_home/etc/auth/certs/dhparam.pem'",
          "rm SSL/ecdhCurveName",
        ];
      }
    }
  }
}

