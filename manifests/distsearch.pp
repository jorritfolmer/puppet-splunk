# vim: ts=2 sw=2 et

class splunk::distsearch (
  $searchpeers = $splunk::searchpeers,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home = $splunk::splunk_home
){
  if $searchpeers == undef {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => 'absent',
      require => [
        Class['splunk::installed'],
      ],
    }
  } else {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => 'present',
      require => [
        Class['splunk::installed'],
      ],
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      mode    => '0600',
      content => template('splunk/distsearch.conf'),
    }
    splunk::addsearchpeers { $searchpeers: }

  }
}

#    augeas { "$splunk_home/etc/system/local/distsearch.conf":
#      require => Class['splunk::installed']
#      lens    => 'Puppet.lns',
#      incl    => "$splunk_home/etc/system/local/distsearch.conf",
#      changes => [
#        "set distributedSearch/servers $blah",
#      ];
#    }

