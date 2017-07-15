# vim: ts=2 sw=2 et

class splunk::server::ssl (
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $ciphersuite = $splunk::ciphersuite,
  $sslversions = $splunk::sslversions,
  $ecdhcurvename = $splunk::ecdhcurvename,
  $requireclientcert = $splunk::requireclientcert,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $splunk_home = $splunk::splunk_home,
  $sslrootcapath = $splunk::sslrootcapath
){
  $splunk_app_name = 'puppet_common_ssl_base'
  file { ["${splunk_home}/etc/apps/${splunk_app_name}",
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

