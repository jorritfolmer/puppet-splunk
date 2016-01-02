# vim: ts=2 sw=2 et
class splunk::installed (
  $package = $splunk::package,
  $splunk_home = $splunk::splunk_home
) {
  package { $package:
    ensure => 'installed',
  }
  exec { 'splunk enable boot-start etcetera':
    command => "${splunk_home}/bin/splunk enable boot-start -user splunk --accept-license --answer-yes --no-prompt",
    path    => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => Package[$package],
    creates => "${splunk_home}/etc/system/local/server.conf",
  }
  service { 'splunk':
    enable  => true,
    require => Exec['splunk enable boot-start etcetera'],
  }
}

