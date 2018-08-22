# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::installed (
  $package = $splunk::package,
  $package_source = $splunk::package_source,
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $version = $splunk::version
) {
  case $::osfamily {
    /^[Ww]indows$/: {
      if $package_source == undef {
        fail('package_source variable is required for Windows installations')
      }
      package { $package:
        ensure          => installed,
        source          => $package_source,
        install_options => ['AGREETOLICENSE=Yes','LAUNCHSPLUNK=0','/quiet'],
      }
    }
    default: {
      if $version == undef and $package_source == undef {
        package { $package:
          ensure => installed,
        }
        -> exec { 'splunk initial run':
          command => "${splunk_home}/bin/splunk version --accept-license --answer-yes --no-prompt",
          path    => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
          require => Package[$package],
          user    => $splunk_os_user,
          creates => "${splunk_home}/etc/system/local/server.conf",
          notify  => Exec['splunk enable boot-start'],
        }
        -> exec { 'splunk enable boot-start':
          command     => "${splunk_home}/bin/splunk enable boot-start -user ${splunk_os_user} --accept-license --answer-yes --no-prompt",
          path        => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
          require     => Package[$package],
          refreshonly => true,
        }
      } elsif $version == undef and $package_source != undef {
        package { $package:
          ensure => installed,
          name   => $package_source,
        }
        -> exec { 'splunk initial run':
          command => "${splunk_home}/bin/splunk version --accept-license --answer-yes --no-prompt",
          path    => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
          require => Package[$package],
          user    => $splunk_os_user,
          creates => "${splunk_home}/etc/system/local/server.conf",
          notify  => Exec['splunk enable boot-start'],
        }
        -> exec { 'splunk enable boot-start':
          command     => "${splunk_home}/bin/splunk enable boot-start -user ${splunk_os_user} --accept-license --answer-yes --no-prompt",
          path        => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
          require     => Package[$package],
          refreshonly => true,
        }
      } else {
        package { $package:
          ensure => $version,
        }
        -> exec { 'splunk initial run':
          command => "${splunk_home}/bin/splunk version --accept-license --answer-yes --no-prompt",
          path    => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
          require => Package[$package],
          user    => $splunk_os_user,
          creates => "${splunk_home}/etc/system/local/server.conf",
          notify  => Exec['splunk enable boot-start'],
        }
        -> exec { 'splunk enable boot-start':
          command     => "${splunk_home}/bin/splunk enable boot-start -user ${splunk_os_user} --accept-license --answer-yes --no-prompt",
          path        => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
          require     => Package[$package],
          refreshonly => true,
        }
      }
    }
  }

}
