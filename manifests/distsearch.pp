# vim: ts=2 sw=2 et
define addsearchpeers {
  $package = $splunk_cluster::params::package
  $splunk_home = $splunk_cluster::splunk_home
  $admin = $splunk_cluster::admin
  $adminpass = $admin[pass]
  
  if $adminpass == undef {
    err("Plaintext admin password not set, skipping addition of search peers to search head")
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

#    augeas { "/opt/splunk/etc/system/local/distsearch.conf":
#      require => Class['splunk_cluster::installed']
#      lens    => 'Puppet.lns',
#      incl    => "/opt/splunk/etc/system/local/distsearch.conf",
#      changes => [
#        "set distributedSearch/servers $blah",
#      ];
#    }

