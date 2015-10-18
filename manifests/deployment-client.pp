# vim: ts=2 sw=2 et
class splunk_cluster::deployment-client 
( 
  $ds = $splunk_cluster::ds
){
  if $dest == '_self' {
    augeas { "/opt/splunk/etc/system/local/deployment-client.conf":
      require => Class['splunk_cluster::installed']
      lens    => 'Puppet.lns',
      incl    => "/opt/splunk/etc/system/local/deployment-client.conf",
      changes => [
        "rm target-broker:deploymentServer"
      ];
    }
  } else {
    augeas { "/opt/splunk/etc/system/local/deployment-client.conf":
      require => Class['splunk_cluster::installed']
      lens    => 'Puppet.lns',
      incl    => "/opt/splunk/etc/system/local/deployment-client.conf",
      changes => [
        "set target-broker:deploymentServer/targetUri $ds"
      ];
    }
  }
}
