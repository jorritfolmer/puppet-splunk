# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::certs::s2s (
  $dhparamsize = $splunk::dhparamsize,
  $package = $splunk::package,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $splunk_home   = $splunk::splunk_home,
  $sslcertpath   = $splunk::sslcertpath,
  $sslrootcapath = $splunk::sslrootcapath,
  $reuse_puppet_certs = $splunk::reuse_puppet_certs
){
  case $::osfamily {
    /^[Ww]indows$/: {
      #################################### WINDOWS #################################
      file { "${splunk_home}/etc/auth/certs":
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_group,
        mode   => $splunk_dir_mode,
      }
      -> exec { 'openssl dhparam':
        command     => "openssl dhparam -outform PEM -out \"${splunk_home}/etc/auth/certs/dhparam.pem\" ${dhparamsize}",
        path        => ["${splunk_home}/bin"],
        environment => "OPENSSL_CONF=${splunk_home}/openssl.cnf",
        creates     => [
          "${splunk_home}/etc/auth/certs/dhparam.pem",
        ],
        # this may take some time
        logoutput   => true,
        timeout     => 900,
      }
      -> file { "${splunk_home}/etc/auth/certs/dhparam.pem":
        owner => $splunk_os_user,
        group => $splunk_os_group,
        mode  => $splunk_file_mode,
      }

      if $reuse_puppet_certs {
        # reuse certs from open source Puppet
        exec { 'openssl s2s ca opensource puppet':
          command     => "powershell -command \"Copy-Item c:/ProgramData/PuppetLabs/puppet/etc/ssl/certs/ca.pem \'${splunk_home}/etc/auth/${sslrootcapath}\'\"",
          path        => ['c:/windows/system32/windowspowershell/v1.0', 'c:/windows/system32', "${splunk_home}/bin"],
          environment => "OPENSSL_CONF=${splunk_home}/openssl.cnf",
          creates     => [ "${splunk_home}/etc/auth/${sslrootcapath}", ],
          require     => File["${splunk_home}/etc/auth/certs"],
          onlyif      => 'powershell -command "Test-Path C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs/ca.pem"'
        }
        -> file { "${splunk_home}/etc/auth/certs/ca.pem":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }
        -> exec { 'openssl s2s 1 opensource puppet':
          command     => "powershell -command \"Get-Content C:/ProgramData/PuppetLabs/puppet/etc/ssl/private_keys/${::fqdn}.pem , C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs/${::fqdn}.pem | Set-Content \'${splunk_home}/etc/auth/${sslcertpath}\'\"",
          path        => ['c:/windows/system32/windowspowershell/v1.0', 'c:/windows/system32', "${splunk_home}/bin"],
          environment => "OPENSSL_CONF=${splunk_home}/openssl.cnf",
          creates     => [ "${splunk_home}/etc/auth/${sslcertpath}", ],
          onlyif      => "powershell -command \"Test-Path C:/ProgramData/PuppetLabs/puppet/etc/ssl/private_keys/${::fqdn}.pem\""
        }
        -> file { "${splunk_home}/etc/auth/${sslcertpath}":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }

      }
    }
    default: {
      #################################### NIX #################################
      file { "${splunk_home}/etc/auth/certs":
        ensure  => directory,
        owner   => $splunk_os_user,
        group   => $splunk_os_group,
        mode    => $splunk_dir_mode,
        recurse => true,
      }
      -> exec { 'openssl dhparam':
        command   => "openssl dhparam -outform PEM -out ${splunk_home}/etc/auth/certs/dhparam.pem ${dhparamsize}",
        user      => $splunk_os_user,
        path      => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
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
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${sslrootcapath}", ],
          require => File["${splunk_home}/etc/auth/certs"],
          onlyif  => '/usr/bin/test -e /etc/puppet/ssl/certs/ca.pem'
        }
        -> exec { 'openssl s2s 1 opensource puppet':
          command => "cat /etc/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${sslcertpath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${sslcertpath}", ],
          onlyif  => "/usr/bin/test -e /etc/puppet/ssl/private_keys/${::fqdn}.pem"
        }

        # reuse certs from commercial Puppet
        -> exec { 'openssl s2s ca commercial puppet':
          command => "cat /etc/puppetlabs/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/${sslrootcapath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${sslrootcapath}", ],
          require => File["${splunk_home}/etc/auth/certs"],
          onlyif  => '/usr/bin/test -e /etc/puppetlabs/puppet/ssl/certs/ca.pem'
        }
        -> exec { 'openssl s2s 1 commercial puppet':
          command => "cat /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${sslcertpath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/certs/s2s.pem", ],
          onlyif  => "/usr/bin/test -e /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem"
        }

        # reuse certs from Red Hat packaged Puppet
        -> exec { 'openssl s2s ca redhat puppet':
          command => "cat /var/lib/puppet/ssl/certs/ca.pem > ${splunk_home}/etc/auth/${sslrootcapath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${sslrootcapath}", ],
          require => File["${splunk_home}/etc/auth/certs"],
          onlyif  => '/usr/bin/test -e /var/lib/puppet/ssl/certs/ca.pem'
        }
        -> exec { 'openssl s2s 1 redhat puppet':
          command => "cat /var/lib/puppet/ssl/private_keys/${::fqdn}.pem /var/lib/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${sslcertpath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/certs/s2s.pem", ],
          onlyif  => "/usr/bin/test -e /var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
        }

        # Fix permissions
        -> file { "${splunk_home}/etc/auth/${sslrootcapath}":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }
        -> file { "${splunk_home}/etc/auth/${sslcertpath}":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }
      }
    }
  }
}
