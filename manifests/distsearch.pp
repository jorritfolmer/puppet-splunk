# vim: ts=2 sw=2 et
define addsearchpeers {
  $package = $splunk::package
  $splunk_home = $splunk::splunk_home
  $admin = $splunk::admin
  $adminpass = $admin[pass]
  
  if $adminpass == undef {
    err("Plaintext admin password not set, skipping addition of search peers to search head")
  } else {
    exec { "splunk add search-server $title":
      command => "splunk add search-server -host $title -auth admin:$adminpass -remoteUsername admin -remotePassword $adminpass && touch $splunk_home/etc/auth/distServerKeys/$title.done",
      path    => ["$splunk_home/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      require => [
        Class['splunk::installed'],
        File["$splunk_home/etc/auth/certs"],
      ],
      creates => [
        "$splunk_home/etc/auth/distServerKeys/$title.done",
      ],
      logoutput => true,
    }
  }
}

class splunk::distsearch ( 
  $searchpeers = $splunk::searchpeers,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home = $splunk::splunk_home,
){
  if $searchpeers == undef {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => "absent"
    }
  } else {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      require => [
        Class['splunk::installed'],
      ],
      ensure  => "present",
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      mode    => 0600,
      content => template("splunk/distsearch.conf"),
    }
    addsearchpeers { $searchpeers: }

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

