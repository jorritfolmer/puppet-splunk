# vim: ts=2 sw=2 et
class splunk::deploymentclient
(
  $ds = $splunk::ds,
  $ds_intermediate = $splunk::ds_intermediate,
  $splunk_home = $splunk::splunk_home
){
  if $ds == undef {
    augeas { "${splunk_home}/etc/system/local/deploymentclient.conf deploymentServer":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/deploymentclient.conf",
      changes => [
        'rm target-broker:deploymentServer'
      ],
    }
  } else {
    augeas { "${splunk_home}/etc/system/local/deploymentclient.conf deploymentServer":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/deploymentclient.conf",
      changes => [
        "set target-broker:deploymentServer/targetUri ${ds}",
        'set deployment-client/disabled false',
      ],
    }
  }
  if $ds_intermediate == undef {
    augeas { "${splunk_home}/etc/system/local/deploymentclient.conf repositoryLocation":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/deploymentclient.conf",
      changes => [
        'rm deployment-client/repositoryLocation',
        'rm deployment-client/serverRepositoryLocationPolicy',
        'rm deployment-client/reloadDSOnAppInstall',
      ],
    }
  } else {
    augeas { "${splunk_home}/etc/system/local/deploymentclient.conf repositoryLocation":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/deploymentclient.conf",
      changes => [
        'set deployment-client/disabled false',
        "set deployment-client/repositoryLocation ${splunk_home}/etc/deployment-apps",
        'set deployment-client/serverRepositoryLocationPolicy rejectAlways',
        'set deployment-client/reloadDSOnAppInstall true',
      ],
    }
  }
}
