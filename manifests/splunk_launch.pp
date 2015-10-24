# vim: ts=2 sw=2 et
class splunk_cluster::splunk_launch ( 
  $splunk_os_user = $splunk_cluster::splunk_os_user
){
  if $splunk_os_user == undef {
    augeas { '/opt/splunk/etc/splunk-launch.conf':
      require => Class['splunk_cluster::installed'],
      lens    => 'ShellVars.lns',
      incl    => '/opt/splunk/etc/splunk-launch.conf',
      changes => [
        'rm SPLUNK_OS_USER',
      ];
    }
  } else {
    augeas { '/opt/splunk/etc/splunk-launch.conf':
      require => Class['splunk_cluster::installed'],
      lens    => 'ShellVars.lns',
      incl    => '/opt/splunk/etc/splunk-launch.conf',
      changes => [
        "set SPLUNK_OS_USER $splunk_os_user",
      ];
    }
  }
}
