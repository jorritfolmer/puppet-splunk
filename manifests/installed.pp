# vim: ts=2 sw=2 et
class splunk::installed (
  $package = $splunk::package,
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::splunk_os_user
) {
  package { $package:
    ensure => 'installed',
  }
  exec { 'splunk enable boot-start etcetera':
    command => "${splunk_home}/bin/splunk enable boot-start -user ${splunk_os_user} --accept-license --answer-yes --no-prompt",
    path    => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => Package[$package],
    creates => "${splunk_home}/etc/system/local/server.conf",
  }
}

