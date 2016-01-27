# vim: ts=2 sw=2 et
class splunk::certs::s2s (
  $dhparamsize = $splunk::dhparamsize,
  $package = $splunk::package,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home = $splunk::splunk_home
){
  file { "${splunk_home}/etc/auth/certs":
    ensure  => directory,
    owner   => $splunk_os_user,
    group   => $splunk_os_user,
    mode    => '0700',
    recurse => true,
    require => [
      Class['splunk::installed'],
      Class['splunk::inputs'],
    ],
  }

  exec { 'openssl dhparam':
    command   => "openssl dhparam -outform PEM -out ${splunk_home}/etc/auth/certs/dhparam.pem ${dhparamsize}",
    path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require   => [
      Class['splunk::installed'],
      File["${splunk_home}/etc/auth/certs"],
    ],
    creates   => [
      "${splunk_home}/etc/auth/certs/dhparam.pem",
    ],
    logoutput => true,
    timeout   => 900,
  }

  exec { 'openssl s2s ca':
    command => "cat /etc/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/certs/ca.crt",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => [
      Class['splunk::installed'],
      File["${splunk_home}/etc/auth/certs"],
    ],
    creates => [
      "${splunk_home}/etc/auth/certs/ca.crt",
    ],
    timeout => 900,
  }

  exec { 'openssl s2s 1':
    command => "cat /etc/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/certs/s2s.pem",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => [
      Class['splunk::installed'],
      Exec['openssl s2s ca'],
    ],
    creates => [
      "${splunk_home}/etc/auth/certs/s2s.pem",
    ],
    timeout => 900,
  }

}

