# vim: ts=2 sw=2 et
class splunk::outputs (
  $tcpout = $splunk::tcpout,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home    = $splunk::splunk_home,
  $useACK         = $splunk::useACK,
){
  if $tcpout == undef {
    file { "${splunk_home}/etc/system/local/outputs.conf":
      ensure  => 'absent',
      require => Class['splunk::installed'],
    }
  } else {
    file { "${splunk_home}/etc/system/local/outputs.conf":
      ensure  => 'present',
      require => Class['splunk::installed'],
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      mode    => '0600',
      content => template('splunk/outputs.conf'),
    }
  }
}

