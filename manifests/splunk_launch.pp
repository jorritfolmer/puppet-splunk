# vim: ts=2 sw=2 et
class splunk::splunk_launch (
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_bindip = $splunk::splunk_bindip,
  $splunk_db = $splunk::splunk_db,
  $splunk_home = $splunk::splunk_home
){
  case $::osfamily {
    /^[Ww]indows$/: {
      notify {'Setting splunk_os_user and splunk_db not supported on Windows':}
      warning('Setting splunk_os_user and splunk_db not supported on Windows')
      # On Windows there is no Augeas
    }
    default: {
      if $splunk_os_user == undef {
        augeas { "${splunk_home}/etc/splunk-launch.conf splunk_os_user":
          lens    => 'ShellVars.lns',
          incl    => "${splunk_home}/etc/splunk-launch.conf",
          changes => [
            'rm SPLUNK_OS_USER',
          ];
        }
      } else {
        augeas { "${splunk_home}/etc/splunk-launch.conf splunk_os_user":
          lens    => 'ShellVars.lns',
          incl    => "${splunk_home}/etc/splunk-launch.conf",
          changes => [
            "set SPLUNK_OS_USER ${splunk_os_user}",
          ];
        }
      }
      if $splunk_bindip == undef {
        augeas { "${splunk_home}/etc/splunk-launch.conf splunk_bindip":
          lens    => 'ShellVars.lns',
          incl    => "${splunk_home}/etc/splunk-launch.conf",
          changes => [
            'rm SPLUNK_BINDIP',
          ];
        }
      } else {
        augeas { "${splunk_home}/etc/splunk-launch.conf splunk_bindip":
          lens    => 'ShellVars.lns',
          incl    => "${splunk_home}/etc/splunk-launch.conf",
          changes => [
            "set SPLUNK_BINDIP ${splunk_bindip}",
          ];
        }
      }
      if $splunk_db == undef {
        #For now, we skip removing SPLUNK_DB if unset, because people may have previously set this manually.
        #Perhaps we'll start removing SPLUNK_DB in a 4.x release
        #augeas { "${splunk_home}/etc/splunk-launch.conf splunk_db":
        #  lens    => 'ShellVars.lns',
        #  incl    => "${splunk_home}/etc/splunk-launch.conf",
        #  changes => [
        #    'rm SPLUNK_DB',
        #  ];
        #}
      } else {
        augeas { "${splunk_home}/etc/splunk-launch.conf splunk_db":
          lens    => 'ShellVars.lns',
          incl    => "${splunk_home}/etc/splunk-launch.conf",
          changes => [
            "set SPLUNK_DB ${splunk_db}",
          ];
        }
      }
    }
  }
}
