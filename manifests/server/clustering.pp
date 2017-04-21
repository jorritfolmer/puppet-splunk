# vim: ts=2 sw=2 et

class splunk::server::clustering (
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $clustering = $splunk::clustering,
  $replication_port = $splunk::replication_port,
){
  $splunk_app_name = 'puppet_indexer_cluster'
  # if no pass4symmkey defined under clustering, default to general
  # pass4symmkey
  if $clustering[pass4symmkey] == undef {
    $pass4symmkey = $splunk::pass4symmkey
  } else {
    $pass4symmkey = $clustering[pass4symmkey]
  }
  case $clustering[mode] {
    'master': {
      $replication_factor = $clustering[replication_factor]
      $search_factor = $clustering[search_factor]
      # site is a reserved word in Puppet 4.x, switching to thissite
      $thissite = $clustering[thissite]
      $multisite = $clustering[multisite]
      $available_sites = $clustering[available_sites]
      $site_replication_factor = $clustering[site_replication_factor]
      $site_search_factor = $clustering[site_search_factor]
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_slave_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_searchhead_base", ]:
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
      -> file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_master_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_master_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_master_base/metadata",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_user,
        mode   => '0700',
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_pass4symmkey_base/local/server.conf"),
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_master_base/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_master_base/local/server.conf"),
      }

    }
    'slave': {
      $cm = $clustering[cm]
      # site is a reserved word in Puppet 4.x, switching to thissite
      $thissite = $clustering[thissite]
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_master_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_searchhead_base", ]:
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
      -> file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_slave_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_slave_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_slave_base/metadata",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_user,
        mode   => '0700',
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_pass4symmkey_base/local/server.conf"),
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_slave_base/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_slave_base/local/server.conf"),
      }

    }
    'searchhead': {
      $cm = $clustering[cm]
      # site is a reserved word in Puppet 4.x, switching to thissite
      $thissite = $clustering[thissite]
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_master_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_slave_base", ]:
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
      -> file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_searchhead_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_searchhead_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_searchhead_base/metadata",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_user,
        mode   => '0700',
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_pass4symmkey_base/local/server.conf"),
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_searchhead_base/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_searchhead_base/local/server.conf"),
      }

    }
    default: {
      # without clustering, remove all clustering config apps
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_slave_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_searchhead_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_master_base", ]:
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
    }
  }
}
