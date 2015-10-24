# vim: ts=2 sw=2 et
class splunk_cluster::distsearch ( 
  $searchpeers = $splunk_cluster::searchpeers,
  $splunk_os_user = $splunk_cluster::splunk_os_user,
  $splunk_home = $splunk_cluster::splunk_home,
){
  if $distributedsearchservers == undef {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => "absent"
    }
  } else {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => "present",
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      mode    => 0600,
      content => template("splunk_cluster/distsearch.conf"),
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

}
