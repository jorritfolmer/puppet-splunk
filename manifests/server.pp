# vim: ts=2 sw=2 et
class splunk_cluster::server::license ( 
  $lm = $splunk_cluster::lm 
){
  if $lm == undef {
    augeas { '/opt/splunk/etc/system/local/server.conf/license':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        'rm license/master_uri',
      ],
    }
  } else {
    augeas { '/opt/splunk/etc/system/local/server.conf/license':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        "set license/master_uri $lm",
      ],
    }
  }
}

class splunk_cluster::server::ssl ( 
  $ciphersuite = $splunk_cluster::ciphersuite,
  $sslversions = $splunk_cluster::sslversions,
  $ecdhcurvename = $splunk_cluster::ecdhcurvename,
  $splunk_home = $splunk_cluster::splunk_home,
){
  augeas { '/opt/splunk/etc/system/local/server.conf/sslConfig':
    require => [ 
      Class['splunk_cluster::installed'],
      Exec["openssl dhparam"],
    ],
    lens    => 'Puppet.lns',
    incl    => '/opt/splunk/etc/system/local/server.conf',
    changes => [
      "set sslConfig/enableSplunkdSSL true",
      "set sslConfig/cipherSuite $ciphersuite",
      "set sslConfig/sslVersions $sslversions",
      "set sslConfig/dhFile $splunk_home/etc/auth/certs/dhparam.pem",
      "set sslConfig/ecdhCurveName $ecdhcurvename",
    ],
  }
}

class splunk_cluster::server::kvstore ( $kvstoreport = $splunk_cluster::kvstoreport ){
  if $kvstoreport == undef {
    augeas { '/opt/splunk/etc/system/local/server.conf/kvstore':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        'rm kvstore/port',
        'set kvstore/disabled true',
      ],
    }
  } else {
    augeas { '/opt/splunk/etc/system/local/server.conf/kvstore':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        "set kvstore/port $kvstoreport",
        'set kvstore/disabled false',
      ];
    }
  }
}

class splunk_cluster::server::clustering ( $mode = undef ){
  if $mode == undef {
    augeas { '/opt/splunk/etc/system/local/server.conf/clustering':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        'rm clustering/mode',
      ],
    }
  } else {
    augeas { '/opt/splunk/etc/system/local/server.conf/clustering':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        "set clustering/mode $mode",
      ],
    }
  }
}
