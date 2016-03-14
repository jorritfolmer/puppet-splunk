# vim: ts=2 sw=2 et

class splunk::server::shclustering (
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::splunk_os_user,
  $shclustering = $splunk::shclustering,
){
  $splunk_app_name = 'puppet_search_shcluster'
  # if no pass4symmkey defined under shclustering, default to general
  # pass4symmkey
  if $shclustering[pass4symmkey] == undef {
    $pass4symmkey = $splunk::pass4symmkey
  } else {
    $pass4symmkey = $shclustering[pass4symmkey]
  }
  if $shclustering == undef {
    $replication_factor = $shclustering[replication_factor]
    file { [
      "${splunk_home}/etc/apps/${splunk_app_name}_base",
      "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base", ]:
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
  } else {
    file { [
      "${splunk_home}/etc/apps/${splunk_app_name}_base",
      "${splunk_home}/etc/apps/${splunk_app_name}_base/local",
      "${splunk_home}/etc/apps/${splunk_app_name}_base/metadata",
      "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base",
      "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/local",
      "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_user,
      mode   => '0700',
    } ->
    file { "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/local/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      content => template("splunk/${splunk_app_name}_pass4symmkey_base/local/server.conf"),
    } ->
    file { "${splunk_home}/etc/apps/${splunk_app_name}_base/local/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      content => template("splunk/${splunk_app_name}_base/local/server.conf"),
    }
  }
}
