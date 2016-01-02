# vim: ts=2 sw=2 et

class splunk::server::kvstore (
  $kvstoreport = $splunk::kvstoreport,
  $splunk_home = $splunk::splunk_home
){
  if $kvstoreport == undef {
    augeas { "${splunk_home}/etc/system/local/server.conf/kvstore":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/server.conf",
      changes => [
        'rm kvstore/port',
        'set kvstore/disabled true',
      ],
    }
  } else {
    augeas { "${splunk_home}/etc/system/local/server.conf/kvstore":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/server.conf",
      changes => [
        "set kvstore/port ${kvstoreport}",
        'set kvstore/disabled false',
      ];
    }
  }
}

