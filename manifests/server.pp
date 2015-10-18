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
      ];
    }
  } else {
    augeas { '/opt/splunk/etc/system/local/server.conf/license':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        "set license/master_uri $lm",
      ];
    }
  }
}

class splunk_cluster::server::ssl ( 
  $ciphersuite = $splunk_cluster::ciphersuite,
  $sslversions = $splunk_cluster::sslversions,
){
  augeas { '/opt/splunk/etc/system/local/server.conf/sslConfig':
    require => Class['splunk_cluster::installed'],
    lens    => 'Puppet.lns',
    incl    => '/opt/splunk/etc/system/local/server.conf',
    changes => [
      "set sslConfig/cipherSuite $ciphersuite",
      "set sslConfig/sslVersions $sslversions",
    ];
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
      ];
    }
  } else {
    augeas { '/opt/splunk/etc/system/local/server.conf/clustering':
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => '/opt/splunk/etc/system/local/server.conf',
      changes => [
        "set clustering/mode $mode",
      ];
    }
  }
}
