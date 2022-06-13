# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::server::general (
  $pass4symmkey = $splunk::pass4symmkey,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $splunk_home = $splunk::splunk_home
){
  $splunk_app_name = 'puppet_common_pass4symmkey_base'
  case $::osfamily {
    /^[Ww]indows$/: {
      # On Windows we cannot delete pass4SymmKey from [general], because there
      # is no Augeas provider on Windows 
    }
    default: {
      # delete pass4SymmKey from [general] in etc/system/local/server.conf,
      # otherwise our pass4SymmKey in the app below will be overruled
      augeas { "${splunk_home}/etc/system/local/server.conf pass4symmkey":
        lens    => 'Splunk.lns',
        incl    => "${splunk_home}/etc/system/local/server.conf",
        changes => [
          'rm target[. = "general"]/pass4SymmKey',
        ],
      }
    }
  }
  file { [
    "${splunk_home}/etc/apps/${splunk_app_name}",
    "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}",
    "${splunk_home}/etc/apps/${splunk_app_name}/metadata",]:
    ensure => directory,
    owner  => $splunk_os_user,
    group  => $splunk_os_group,
    mode   => $splunk_dir_mode,
  }
  -> file { "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}/server.conf":
    ensure  => present,
    owner   => $splunk_os_user,
    group   => $splunk_os_group,
    mode    => $splunk_file_mode,
    replace => $splunk_app_replace,
    content => template("splunk/${splunk_app_name}/local/server.conf"),
  }
}

