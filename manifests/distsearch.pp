# vim: ts=2 sw=2 et
class splunk_cluster::sh ( 
  $indexers = $splunk_cluster::indexers 
){
  if $indexers == undef {
    augeas { "/opt/splunk/etc/system/local/distsearch.conf":
      require => Class['splunk_cluster::installed']
      lens    => 'Puppet.lns',
      incl    => "/opt/splunk/etc/system/local/distsearch.conf",
      changes => [
        "rm distributedSearch",
      ];
    }
  } else {
    augeas { "/opt/splunk/etc/system/local/distsearch.conf":
      require => Class['splunk_cluster::installed']
      lens    => 'Puppet.lns',
      incl    => "/opt/splunk/etc/system/local/distsearch.conf",
      changes => [
        "set distributedSearch/servers $indexers",
      ];
    }
  }
}
