# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::service (
  $type = $splunk::type,
  $splunk_home = $splunk::splunk_home,
  $service = $splunk::service
) {
  case $::osfamily {
    /^[Ww]indows$/: {
      case $type {
        'uf':    { $windows_service = 'SplunkForwarder' }
        default: { $windows_service = 'Splunkd' }
      }
      if $service[ensure] == undef {
        service { $windows_service:
          enable  => $service[enable],
        }
      } else {
        service { $windows_service:
          ensure => $service[ensure],
          enable => $service[enable],
        }
      }
    }
    default: {
      if $service[ensure] == undef {
        service { 'splunk':
          enable => $service[enable],
          status => "${splunk_home}/bin/splunk status",
          start  => "${splunk_home}/bin/splunk start",
          stop   => "${splunk_home}/bin/splunk stop",
        }
      } else {
        service { 'splunk':
          ensure => $service[ensure],
          enable => $service[enable],
          status => "${splunk_home}/bin/splunk status",
          start  => "${splunk_home}/bin/splunk start",
          stop   => "${splunk_home}/bin/splunk stop",
        }
      }
    }
  }
}

