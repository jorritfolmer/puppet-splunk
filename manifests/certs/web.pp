# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::certs::web (
  $package = $splunk::package,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $splunk_home = $splunk::splunk_home,
  $privkeypath = $splunk::privkeypath,
  $servercert = $splunk::servercert,
  $reuse_puppet_certs_for_web = $splunk::reuse_puppet_certs_for_web
){
  case $::osfamily {
    /^[Ww]indows$/: {
      #################################### WINDOWS #################################
      if $reuse_puppet_certs_for_web {
        # reuse certs from open source Puppet
        exec { 'openssl web privkey opensource puppet':
          command     => "powershell -command \"Copy-Item c:/ProgramData/PuppetLabs/puppet/etc/ssl/private_keys/${::fqdn}.pem \'${splunk_home}/etc/auth/${privkeypath}\'\"",
          path        => ['c:/windows/system32/windowspowershell/v1.0', 'c:/windows/system32', "${splunk_home}/bin"],
          environment => "OPENSSL_CONF=${splunk_home}/openssl.cnf",
          creates     => [ "${splunk_home}/etc/auth/${privkeypath}", ],
          require     => File["${splunk_home}/etc/auth/certs"],
          onlyif      => "powershell -command \"Test-Path C:/ProgramData/PuppetLabs/puppet/etc/ssl/private_keys/${::fqdn}.pem\""
        }
        -> file { "${splunk_home}/etc/auth/certs/${privkeypath}":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }
        -> exec { 'openssl web cert opensource puppet':
          command     => "powershell -command \"Copy-Item C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs/${::fqdn}.pem \'${splunk_home}/etc/auth/${servercert}\'\"",
          path        => ['c:/windows/system32/windowspowershell/v1.0', 'c:/windows/system32', "${splunk_home}/bin"],
          environment => "OPENSSL_CONF=${splunk_home}/openssl.cnf",
          creates     => [ "${splunk_home}/etc/auth/${servercert}", ],
          onlyif      => "powershell -command \"Test-Path C:/ProgramData/PuppetLabs/puppet/etc/ssl/certs/${::fqdn}.pem\""
        }
        -> file { "${splunk_home}/etc/auth/${servercert}":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }

      }
    }
    default: {
      #################################### NIX #################################
      if $reuse_puppet_certs_for_web {
        # reuse certs from open source Puppet
        exec { 'openssl web privkey opensource puppet':
          command => "cat /etc/puppet/ssl/private_keys/${::fqdn}.pem > ${splunk_home}/etc/auth/${privkeypath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${privkeypath}", ],
          onlyif  => "/usr/bin/test -e /etc/puppet/ssl/private_keys/${::fqdn}.pem"
        }
        -> exec { 'openssl web cert opensource puppet':
          command => "cat /etc/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${servercert}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${servercert}", ],
          onlyif  => "/usr/bin/test -e /etc/puppet/ssl/certs/${::fqdn}.pem"
        }
        # reuse certs from commercial Puppet
        -> exec { 'openssl web privkey commercial puppet':
          command => "cat /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem > ${splunk_home}/etc/auth/${privkeypath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${privkeypath}", ],
          onlyif  => "/usr/bin/test -e /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem"
        }
        -> exec { 'openssl web cert commercial puppet':
          command => "cat /etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem > ${splunk_home}/etc/auth/${servercert}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${servercert}", ],
          onlyif  => "/usr/bin/test -e /etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem"
        }
        # reuse certs from Red Hat packaged Puppet
        -> exec { 'openssl web privkey redhat puppet':
          command => "cat /var/lib/puppet/ssl/private_keys/${::fqdn}.pem > ${splunk_home}/etc/auth/${privkeypath}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${privkeypath}", ],
          onlyif  => "/usr/bin/test -e /var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
        }
        -> exec { 'openssl web cert redhat puppet':
          command => "cat /var/lib/puppet/ssl/private_keys/${::fqdn}.pem > ${splunk_home}/etc/auth/${servercert}",
          path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', "${splunk_home}/bin"],
          creates => [ "${splunk_home}/etc/auth/${servercert}", ],
          onlyif  => "/usr/bin/test -e /var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
        }

        # Fix permissions
        -> file { "${splunk_home}/etc/auth/${privkeypath}":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }
        -> file { "${splunk_home}/etc/auth/${servercert}":
          owner => $splunk_os_user,
          group => $splunk_os_group,
          mode  => $splunk_file_mode,
        }
      }
    }
  }
}
