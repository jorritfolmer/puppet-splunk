# vim: ts=2 sw=2 et
class splunk::secret (
  $splunk_home = $splunk::splunk_home,
  $splunk_secret = $splunk::secret,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode
){
  if $splunk_secret != undef {
    file { "${splunk_home}/etc/auth/splunk.secret":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_group,
      mode    => $splunk_file_mode,
      content => $splunk_secret
    }
  }
}

