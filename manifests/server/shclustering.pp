# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::server::shclustering (
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $shclustering = $splunk::shclustering,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir
){
  $splunk_app_name = 'puppet_search_shcluster'
  if $shclustering[pass4symmkey] == undef {
    $pass4symmkey = $splunk::pass4symmkey
  } else {
    $pass4symmkey = $shclustering[pass4symmkey]
  }
  case $shclustering[mode] {
    'searchhead':          {
      case $::osfamily {
        /^[Ww]indows$/: {
          # On Windows there is no Augeas
        }
        default: {
          # remove previous shclustering config apps if shclustering is not set
          # create both base config and secret key for shclustering if searchhead deployer is set
          $replication_factor = $shclustering[replication_factor]
          $shd = $shclustering[shd]
          $label = $shclustering[label]
          file { [
            "${splunk_home}/etc/apps/${splunk_app_name}_base",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/${splunk_app_precedence_dir}",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/metadata",
            "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base",
            "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}",
            "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/metadata",]:
            ensure => directory,
            owner  => $splunk_os_user,
            group  => $splunk_os_group,
            mode   => $splunk_dir_mode,
          }
          -> file { "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}/server.conf":
            ensure  => present,
            owner   => $splunk_os_user,
            group   => $splunk_os_group,
            replace => $splunk_app_replace,
            content => template("splunk/${splunk_app_name}_pass4symmkey_base/local/server.conf"),
          }
          -> file { "${splunk_home}/etc/apps/${splunk_app_name}_base/${splunk_app_precedence_dir}/server.conf":
            ensure  => present,
            owner   => $splunk_os_user,
            group   => $splunk_os_group,
            replace => $splunk_app_replace,
            content => template("splunk/${splunk_app_name}_base/local/server.conf"),
          }
          # unfortunately we need to edit etc/system/local/server.conf directly,
          # to prevent the SH Deployer from overwriting server specific config
          # directives like mgmt_uri 
          -> augeas { "${splunk_home}/etc/system/local/server.conf/shclustering":
            lens    => 'Splunk.lns',
            incl    => "${splunk_home}/etc/system/local/server.conf",
            changes => [
              "set target[. = 'shclustering']/mgmt_uri https://${::fqdn}:8089",
            ],
          }
        }
      }
    }
    'deployer': {
      # just create a secret key for shclustering, to make the node a search head deployer
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_group,
        mode   => $splunk_dir_mode,
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_pass4symmkey_base/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_group,
        mode    => $splunk_file_mode,
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
