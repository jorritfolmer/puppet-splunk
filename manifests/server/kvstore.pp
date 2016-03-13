# vim: ts=2 sw=2 et

class splunk::server::kvstore (
  $kvstoreport = $splunk::kvstoreport,
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::splunk_os_user
){
  $splunk_app_name = 'puppet_common_kvstore'
  if $kvstoreport == undef {
    file {"${splunk_home}/etc/apps/${splunk_app_name}_base":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    } ->
    file { ["${splunk_home}/etc/apps/${splunk_app_name}_disabled",
            "${splunk_home}/etc/apps/${splunk_app_name}_disabled/local",
            "${splunk_home}/etc/apps/${splunk_app_name}_disabled/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_user,
      mode   => '0700',
    } ->
    file { "${splunk_home}/etc/apps/${splunk_app_name}_disabled/local/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      # re-use the _base template, but created on the client as _disabled
      content => template("splunk/${splunk_app_name}_base/local/server.conf"),
    }
  } else {
    file {"${splunk_home}/etc/apps/${splunk_app_name}_disabled":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    } ->
    file { ["${splunk_home}/etc/apps/${splunk_app_name}_base",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/local",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_user,
      mode   => '0700',
    } ->
    file { "${splunk_home}/etc/apps/${splunk_app_name}_base/local/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      content => template("splunk/${splunk_app_name}_base/local/server.conf"),
    }

  }
}

