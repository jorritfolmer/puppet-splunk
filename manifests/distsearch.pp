# vim: ts=2 sw=2 et
define addsearchpeers {
  $package = $splunk_cluster::params::package
  $splunk_home = $splunk_cluster::splunk_home
  $adminpass = $splunk_cluster::adminpass
  
  if $adminpass == undef {
    err("adminpass not set")
  } else {
    exec { "splunk add search-server $title":
      command => "splunk add search-server -host $title -auth admin:$adminpass -remoteUsername admin -remotePassword $adminpass && touch $splunk_home/etc/auth/distServerKeys/$title.done",
      path    => ["$splunk_home/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      require => [
        Class['splunk_cluster::installed'],
        File["$splunk_home/etc/auth/certs"],
      ],
      creates => [
        "$splunk_home/etc/auth/distServerKeys/$title.done",
      ],
      logoutput => true,
    }
  }
}

class splunk_cluster::distsearch ( 
  $searchpeers = $splunk_cluster::searchpeers,
  $splunk_os_user = $splunk_cluster::splunk_os_user,
  $splunk_home = $splunk_cluster::splunk_home,
){
  if $searchpeers == undef {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => "absent"
    }
  } else {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      require => [
        Class['splunk_cluster::installed'],
      ],
      ensure  => "present",
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      mode    => 0600,
      content => template("splunk_cluster/distsearch.conf"),
    }
    addsearchpeers { $searchpeers: }

  }
}

#  if $indexers == undef {
#    augeas { "/opt/splunk/etc/system/local/distsearch.conf":
#      require => Class['splunk_cluster::installed']
#      lens    => 'Puppet.lns',
#      incl    => "/opt/splunk/etc/system/local/distsearch.conf",
#      changes => [
#        "rm distributedSearch",
#      ];
#    }
#  } else {
#    augeas { "/opt/splunk/etc/system/local/distsearch.conf":
#      require => Class['splunk_cluster::installed']
#      lens    => 'Puppet.lns',
#      incl    => "/opt/splunk/etc/system/local/distsearch.conf",
#      changes => [
#        "set distributedSearch/servers $distributedsearchservers",
#      ];
#    }
#  }

