# vim: ts=2 sw=2 et
class splunk::server::license (
  $lm = $splunk::lm,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home = $splunk::splunk_home
){
  $splunk_app_name = 'puppet_common_license_client_base'
  if $lm == undef {
    file {"${splunk_home}/etc/apps/${splunk_app_name}":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
  } else {
    file { ["${splunk_home}/etc/apps/${splunk_app_name}",
            "${splunk_home}/etc/apps/${splunk_app_name}/local",
            "${splunk_home}/etc/apps/${splunk_app_name}/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_user,
      mode   => '0700',
    } ->
    file { "${splunk_home}/etc/apps/${splunk_app_name}/local/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      content => template("splunk/${splunk_app_name}/local/server.conf"),
    }
  }
}

