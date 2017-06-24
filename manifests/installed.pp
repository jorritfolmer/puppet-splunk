# vim: ts=2 sw=2 et
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
      if $version == undef {
        package { $package:
          ensure => installed,
        }
      } else {
        package { $package:
          ensure => $version,
        }
      }
      exec { 'splunk enable boot-start etcetera':
        command => "${splunk_home}/bin/splunk enable boot-start -user ${splunk_os_user} --accept-license --answer-yes --no-prompt",
        path    => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
        require => Package[$package],
        creates => "${splunk_home}/etc/system/local/server.conf",
      }
    }
  }

}
