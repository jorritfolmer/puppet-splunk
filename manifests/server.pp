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
  if $ecdhcurvename == undef {
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
        "rm sslConfig/ecdhCurveName",
      ],
    }
  } else {
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
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::splunk_os_user,
  $clustering = $splunk::clustering
){
  case $clustering[mode] {
    'master': {
      $replication_factor = $clustering[replication_factor]
      $search_factor = $clustering[search_factor]
      $pass4SymmKey = $clustering[pass4SymmKey]
      augeas { "$splunk_home/etc/system/local/server.conf/clustering":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "$splunk_home/etc/system/local/server.conf",
        changes => [
          "set clustering/mode master",
          "set clustering/replication_factor $replication_factor",
          "set clustering/search_factor $search_factor",
        ],
      }
      file { "$splunk_home/etc/apps/zz_replication_port/default/server.conf":
        ensure  => absent,
      }
    }
    'slave': {
      $cm = $clustering[cm]
      $pass4SymmKey = $clustering[pass4SymmKey]
      augeas { "$splunk_home/etc/system/local/server.conf/clustering":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "$splunk_home/etc/system/local/server.conf",
        changes => [
          "set clustering/mode slave",
          "set clustering/master_uri https://$cm",
          "set clustering/#comment 'replication_port is set in $splunk_home/etc/apps/zz_replication_port/default/server.conf'",
        ],
      }
      file { [ "$splunk_home/etc/apps/zz_replication_port", "$splunk_home/etc/apps/zz_replication_port/default" ]:
        ensure  => directory,
        mode    => 0700,
        owner   => $splunk_os_user,
        require => Augeas["$splunk_home/etc/system/local/server.conf/clustering"],
      }
      file { "$splunk_home/etc/apps/zz_replication_port/default/server.conf":
        ensure  => present,
        mode    => 0700,
        owner   => $splunk_os_user,
        content => "[replication_port://9887]\n",
        require => File["$splunk_home/etc/apps/zz_replication_port/default"],
      }
    }
    'searchhead': {
      $cm = $clustering[cm]
      $pass4SymmKey = $clustering[pass4SymmKey]
      augeas { "$splunk_home/etc/system/local/server.conf/clustering":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "$splunk_home/etc/system/local/server.conf",
        changes => [
          "set clustering/mode searchhead",
          "set clustering/master_uri https://$cm",
        ],
      }
      file { "$splunk_home/etc/apps/zz_replication_port/default/server.conf":
        ensure  => absent,
      }
    }
    default: {
      augeas { "$splunk_home/etc/system/local/server.conf/clustering":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "$splunk_home/etc/system/local/server.conf",
        changes => [
          'rm clustering',
          "rm replication_port:9887",
        ],
      }
      file { "$splunk_home/etc/apps/zz_replication_port/default/server.conf":
        ensure  => absent,
      }
    }
  }
}
