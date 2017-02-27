# vim: ts=2 sw=2 et

class splunk::server::diskusage (
  $minfreespace = $splunk::minfreespace,
  $inputport = $splunk::inputport,
  $splunk_home = $splunk::splunk_home,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $splunk_os_user = $splunk::splunk_os_user
){
  $splunk_app_name = 'puppet_common_diskusage'
  if $minfreespace == undef {
    file {"${splunk_home}/etc/apps/${splunk_app_name}_base":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
  } else {
    file { ["${splunk_home}/etc/apps/${splunk_app_name}_base",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/${splunk_app_precedence_dir}",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_user,
      mode   => '0700',
    } ->
    file { "${splunk_home}/etc/apps/${splunk_app_name}_base/${splunk_app_precedence_dir}/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      replace => $splunk_app_replace,
      content => template("splunk/${splunk_app_name}_base/local/server.conf"),
    }

  }
}

