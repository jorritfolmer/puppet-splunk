# vim: ts=2 sw=2 et
class splunk::outputs (
  $tcpout = $splunk::tcpout,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home    = $splunk::splunk_home,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $use_ack         = $splunk::use_ack,
  $sslrootcapath   = $splunk::sslrootcapath,
  $sslcertpath   = $splunk::sslcertpath
){
  $splunk_app_name = 'puppet_common_ssl_outputs'
  if $tcpout == undef {
    file {"${splunk_home}/etc/apps/${splunk_app_name}":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
  } else {
    file { ["${splunk_home}/etc/apps/${splunk_app_name}",
            "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}",
            "${splunk_home}/etc/apps/${splunk_app_name}/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_user,
      mode   => '0700',
    }
    -> file { "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}/outputs.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      replace => $splunk_app_replace,
      content => template("splunk/${splunk_app_name}/local/outputs.conf"),
    }
  }
}

