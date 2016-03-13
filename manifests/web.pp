# vim: ts=2 sw=2 et
class splunk::web (
  $ciphersuite = $splunk::ciphersuite,
  $sslversions = $splunk::sslversions,
  $httpport = $splunk::httpport,
  $ecdhcurvename = $splunk::ecdhcurvename,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home = $splunk::splunk_home
){
  $splunk_app_name = 'puppet_common_ssl_web'
  if $httpport == undef {
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
    file { "${splunk_home}/etc/apps/${splunk_app_name}_disabled/local/web.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      content => template("splunk/${splunk_app_name}_base/local/web.conf"),
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
    file { "${splunk_home}/etc/apps/${splunk_app_name}_base/local/web.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      content => template("splunk/${splunk_app_name}_base/local/web.conf"),
    }

  }
}
