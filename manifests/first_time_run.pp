# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::first_time_run (
  $package = $splunk::package,
  $package_source = $splunk::package_source,
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $version = $splunk::version
) {
  case $::osfamily {
    /^[Ww]indows$/: {
      # Do nothing
    }
    default: {
      exec { 'splunk first time run':
        command => "${splunk_home}/bin/splunk ftr -user ${splunk_os_user} --accept-license --answer-yes --no-prompt",
        path    => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
        require => Package[$package],
        user    => $splunk_os_user,
        onlyif  => "/usr/bin/test -e ${splunk_home}/ftr"
      }
    }
  }
}
