# vim: ts=2 sw=2 et
class splunk::server::license ( 
  $lm = $splunk::lm,
  $splunk_home = $splunk::splunk_home
){
  if $lm == undef {
    augeas { "$splunk_home/etc/system/local/server.conf/license":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "$splunk_home/etc/system/local/server.conf",
      changes => [
        'rm license/master_uri',
      ],
    }
  } else {
    augeas { "$splunk_home/etc/system/local/server.conf/license":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "$splunk_home/etc/system/local/server.conf",
      changes => [
        "set license/master_uri https://$lm",
      ],
    }
  }
}

class splunk::server::ssl ( 
  $ciphersuite = $splunk::ciphersuite,
  $sslversions = $splunk::sslversions,
  $ecdhcurvename = $splunk::ecdhcurvename,
  $splunk_home = $splunk::splunk_home,
){
  augeas { "$splunk_home/etc/system/local/server.conf/sslConfig":
    require => [ 
      Class['splunk::installed'],
      Exec["openssl dhparam"],
    ],
    lens    => 'Puppet.lns',
    incl    => "$splunk_home/etc/system/local/server.conf",
    changes => [
      "set sslConfig/enableSplunkdSSL true",
      "set sslConfig/cipherSuite $ciphersuite",
      "set sslConfig/sslVersions $sslversions",
      "set sslConfig/dhFile $splunk_home/etc/auth/certs/dhparam.pem",
      "set sslConfig/ecdhCurveName $ecdhcurvename",
    ],
  }
}

class splunk::server::kvstore ( 
  $kvstoreport = $splunk::kvstoreport,
  $splunk_home = $splunk::splunk_home
){
  if $kvstoreport == undef {
    augeas { "$splunk_home/etc/system/local/server.conf/kvstore":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "$splunk_home/etc/system/local/server.conf",
      changes => [
        'rm kvstore/port',
        'set kvstore/disabled true',
      ],
    }
  } else {
    augeas { "$splunk_home/etc/system/local/server.conf/kvstore":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "$splunk_home/etc/system/local/server.conf",
      changes => [
        "set kvstore/port $kvstoreport",
        'set kvstore/disabled false',
      ];
    }
  }
}

class splunk::server::clustering ( 
  $mode = undef,
  $splunk_home = $splunk::splunk_home
){
  if $mode == undef {
    augeas { "$splunk_home/etc/system/local/server.conf/clustering":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "$splunk_home/etc/system/local/server.conf",
      changes => [
        'rm clustering/mode',
      ],
    }
  } else {
    augeas { "$splunk_home/etc/system/local/server.conf/clustering":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "$splunk_home/etc/system/local/server.conf",
      changes => [
        "set clustering/mode $mode",
      ],
    }
  }
}
