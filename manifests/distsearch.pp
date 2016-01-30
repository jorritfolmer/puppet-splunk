# vim: ts=2 sw=2 et

class splunk::distsearch (
  $searchpeers = $splunk::searchpeers,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home = $splunk::splunk_home
){
  if $searchpeers == undef {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => 'absent',
    }
  } else {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => 'present',
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      mode    => '0600',
      content => template('splunk/distsearch.conf'),
    }
    splunk::addsearchpeers { $searchpeers: }

  }
}
