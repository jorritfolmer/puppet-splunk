# vim: ts=2 sw=2 et
class splunk::server::general (
  $pass4symmkey = $splunk::pass4symmkey,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $splunk_home = $splunk::splunk_home
){
  $splunk_app_name = 'puppet_common_pass4symmkey_base'
  # delete pass4SymmKey from [general], otherwise our pass4SymmKey in the app below
  # will be overruled
  augeas { "${splunk_home}/etc/system/local/server.conf pass4symmkey":
    lens    => 'Puppet.lns',
    incl    => "${splunk_home}/etc/system/local/server.conf",
    changes => [
      'rm general/pass4SymmKey',
    ],
  }
  file { [
    "${splunk_home}/etc/apps/${splunk_app_name}",
    "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}",
    "${splunk_home}/etc/apps/${splunk_app_name}/metadata",]:
    ensure => directory,
    owner  => $splunk_os_user,
    group  => $splunk_os_user,
    mode   => '0700',
  }
  -> file { "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}/server.conf":
    ensure  => present,
    owner   => $splunk_os_user,
    group   => $splunk_os_user,
    replace => $splunk_app_replace,
    content => template("splunk/${splunk_app_name}/local/server.conf"),
  }
}

