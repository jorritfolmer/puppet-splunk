# vim: ts=2 sw=2 et
class splunk_cluster::installed ( 
  $package = $splunk_cluster::package
) {
  package { $package:
    ensure => 'installed',
  }
  exec { 'splunk enable boot-start etcetera':
    command => '/opt/splunk/bin/splunk enable boot-start -user splunk --accept-license --answer-yes --no-prompt',
    path    => ['/opt/splunk/bin', '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => Package[$package],
    creates => '/opt/splunk/etc/system/local/server.conf',
  }
  service { 'splunk':
    enable  => true,
    require => Exec['splunk enable boot-start etcetera'],
  }
}

