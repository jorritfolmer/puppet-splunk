# vim: ts=2 sw=2 et
class splunk_cluster::deploymentclient 
( 
  $ds = $splunk_cluster::ds
){
  if $ds == undef {
    augeas { "/opt/splunk/etc/system/local/deploymentclient.conf":
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => "/opt/splunk/etc/system/local/deploymentclient.conf",
      changes => [
        "rm target-broker:deploymentServer"
      ],
    }
  } else {
    augeas { "/opt/splunk/etc/system/local/deploymentclient.conf":
      require => Class['splunk_cluster::installed'],
      lens    => 'Puppet.lns',
      incl    => "/opt/splunk/etc/system/local/deploymentclient.conf",
      changes => [
        "set target-broker:deploymentServer/targetUri $ds"
      ],
    }
  }
}
