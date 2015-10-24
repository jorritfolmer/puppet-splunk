# vim: ts=2 sw=2 et
class splunk_cluster::outputs ( 
  $tcpout = $splunk_cluster::tcpout,
  $splunk_os_user = $splunk_cluster::splunk_os_user,
  $splunk_home    = $splunk_cluster::splunk_home,
){
  if $tcpout == undef {
    file { "${splunk_home}/etc/system/local/outputs.conf":
      ensure  => "absent"
    }
  } else {
    file { "${splunk_home}/etc/system/local/outputs.conf":
      ensure  => "present", 
      owner   => $splunk_os_user,
      group   => $splunk_os_user,
      mode    => 0600,
      content => template("splunk_cluster/outputs.conf"),
    }
  }
}

