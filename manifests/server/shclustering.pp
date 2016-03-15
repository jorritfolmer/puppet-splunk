# vim: ts=2 sw=2 et

class splunk::server::shclustering (
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::splunk_os_user,
  $shclustering = $splunk::shclustering
){
  $splunk_app_name = 'puppet_search_shcluster'
  if $shclustering[pass4symmkey] == undef {
    $pass4symmkey = $splunk::pass4symmkey
  } else {
    $pass4symmkey = $shclustering[pass4symmkey]
  }
  case $shclustering[mode] {
    'searchhead':          {
      # remove previous shclustering config apps if shclustering is not set
      # create both base config and secret key for shclustering if searchhead deployer is set
      $replication_factor = $shclustering[replication_factor]
      $shd = $shclustering[shd]
      $label = $shclustering[label]
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
    'deployer': {
      # just create a secret key for shclustering, to make the node a search head deployer
      file { [
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
      }
    }
    default: {
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base", ]:
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
    }
  }
}
