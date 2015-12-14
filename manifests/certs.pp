# vim: ts=2 sw=2 et
class splunk::certs::s2s ( 
  $dhparamsize = $splunk::dhparamsize,
  $package = $splunk::package,
  $splunk_os_user = $splunk::splunk_os_user,
  $splunk_home = $splunk::splunk_home,
){
  file { "$splunk_home/etc/auth/certs":
    ensure  => directory,
    owner   => $splunk_os_user,
    group   => $splunk_os_user,
    mode    => 0700,
    recurse => true,
    require => Augeas["$splunk_home/etc/system/local/inputs.conf"],
  }

  file { "$splunk_home/etc/auth/certs/ca.crt":
    ensure  => present,
    owner   => $splunk_os_user,
    group   => $splunk_os_user,
    mode    => 0700,
    require => File["$splunk_home/etc/auth/certs"],
    source  => "puppet:///ca/ca.crt",
  }

  exec { 'openssl dhparam':
    command => "openssl dhparam -outform PEM -out $splunk_home/etc/auth/certs/dhparam.pem $dhparamsize",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => [ 
      Package[$package],
      File["$splunk_home/etc/auth/certs"],
    ],
    creates => [ 
      "$splunk_home/etc/auth/certs/dhparam.pem",
    ],
    logoutput => true,
  }


  exec { 'openssl s2s 1':
    command => "openssl req -new -x509 -nodes -newkey rsa:2048 -keyout $splunk_home/etc/auth/certs/s2s.key -out $splunk_home/etc/auth/certs/s2s.crt -days 3650 -subj \"/C=NL/ST=Zuid-Holland/L=Rotterdam/O=Bedrijf/CN=$fqdn\" ",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => [ 
      Package[$package],
      File["$splunk_home/etc/auth/certs"],
    ],
    creates => [ 
      "$splunk_home/etc/auth/certs/s2s.crt",
    ],
  }

  exec { 'openssl s2s 2':
    command => "cat $splunk_home/etc/auth/certs/s2s.key $splunk_home/etc/auth/certs/s2s.crt > $splunk_home/etc/auth/certs/s2s.pem",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    require => [ 
      Package[$package],
      Exec['openssl s2s 1'],
    ],
    creates => [ 
      "$splunk_home/etc/auth/certs/s2s.pem",
    ],
  }

}

class splunk::certs::web ( 
){
}

