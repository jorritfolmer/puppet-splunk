# vim: ts=2 sw=2 et
class splunk::certs::s2s (
  $dhparamsize = $splunk::dhparamsize,
  $package = $splunk::package,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home   = $splunk::splunk_home,
  $use_certs     = $splunk::use_certs,
  $sslcertpath   = $splunk::sslcertpath,
  $sslrootcapath = $splunk::sslrootcapath,
  $reuse_puppet_certs = $splunk::reuse_puppet_certs
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

  if $reuse_puppet_certs {
    # reuse certs from open source Puppet
    exec { 'openssl s2s ca opensource puppet':
      command => "cat /etc/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/${sslrootcapath}",
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      creates => [ "${splunk_home}/etc/auth/${sslrootcapath}", ],
      require => File["${splunk_home}/etc/auth/certs"],
      onlyif  => '/usr/bin/test -e /etc/puppet/ssl/certs/ca.pem'
    } ->
    exec { 'openssl s2s 1 opensource puppet':
      command => "cat /etc/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${sslcertpath}",
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      creates => [ "${splunk_home}/etc/auth/${sslcertpath}", ],
      onlyif  => "/usr/bin/test -e /etc/puppet/ssl/private_keys/${::fqdn}.pem"
    }

    # reuse certs from commercial Puppet
    exec { 'openssl s2s ca commercial puppet':
      command => "cat /etc/puppetlabs/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/${sslrootcapath}",
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      creates => [ "${splunk_home}/etc/auth/${sslrootcapath}", ],
      require => File["${splunk_home}/etc/auth/certs"],
      onlyif  => '/usr/bin/test -e /etc/puppetlabs/puppet/ssl/certs/ca.pem'
    } ->
    exec { 'openssl s2s 1 commercial puppet':
      command => "cat /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${sslcertpath}",
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      creates => [ "${splunk_home}/etc/auth/certs/s2s.pem", ],
      onlyif  => "/usr/bin/test -e /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem"
    }

    # reuse certs from Red Hat packaged Puppet
    exec { 'openssl s2s ca redhat puppet':
      command => "cat /var/lib/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/${sslrootcapath}",
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      creates => [ "${splunk_home}/etc/auth/${sslrootcapath}", ],
      require => File["${splunk_home}/etc/auth/certs"],
      onlyif  => '/usr/bin/test -e /var/lib/puppet/ssl/certs/ca.pem'
    } ->
    exec { 'openssl s2s 1 redhat puppet':
      command => "cat /var/lib/puppet/ssl/private_keys/${::fqdn}.pem /var/lib/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${sslcertpath}",
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      creates => [ "${splunk_home}/etc/auth/certs/s2s.pem", ],
      onlyif  => "/usr/bin/test -e /var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
    }
  }
}
