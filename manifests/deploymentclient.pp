# vim: ts=2 sw=2 et
class splunk::deploymentclient
(
  $ds = $splunk::ds,
  $splunk_home = $splunk::splunk_home
){
  if $ds == undef {
    augeas { "${splunk_home}/etc/system/local/deploymentclient.conf":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/deploymentclient.conf",
      changes => [
        'rm target-broker:deploymentServer'
      ],
    }
  } else {
    augeas { "${splunk_home}/etc/system/local/deploymentclient.conf":
      require => Class['splunk::installed'],
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/deploymentclient.conf",
      changes => [
        "set target-broker:deploymentServer/targetUri ${ds}"
      ],
    }
  }
}
