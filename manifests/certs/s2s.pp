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
  } ->
  exec { 'openssl dhparam':
    command   => "openssl dhparam -outform PEM -out ${splunk_home}/etc/auth/certs/dhparam.pem ${dhparamsize}",
    path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    creates   => [
      "${splunk_home}/etc/auth/certs/dhparam.pem",
    ],
    # this may take some time
    logoutput => true,
    timeout   => 900,
  }

  # reuse certs from open source Puppet
  exec { 'openssl s2s ca opensource puppet':
    command => "cat /etc/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/certs/ca.crt",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    creates => [ "${splunk_home}/etc/auth/certs/ca.crt", ],
    require => File["${splunk_home}/etc/auth/certs"],
    onlyif  => '/usr/bin/test -e /etc/puppet/ssl'
  } ->
  exec { 'openssl s2s 1 opensource puppet':
    command => "cat /etc/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/certs/s2s.pem",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    creates => [ "${splunk_home}/etc/auth/certs/s2s.pem", ],
  }

  # reuse certs from commercial Puppet
  exec { 'openssl s2s ca commercial puppet':
    command => "cat /etc/puppetlabs/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/certs/ca.crt",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    creates => [ "${splunk_home}/etc/auth/certs/ca.crt", ],
    require => File["${splunk_home}/etc/auth/certs"],
    onlyif  => '/usr/bin/test -e /etc/puppetlabs/puppet/ssl'
  } ->
  exec { 'openssl s2s 1 commercial puppet':
    command => "cat /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/certs/s2s.pem",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    creates => [ "${splunk_home}/etc/auth/certs/s2s.pem", ],
  }

}

