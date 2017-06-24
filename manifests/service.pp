# vim: ts=2 sw=2 et
class splunk::service (
  $type = $splunk::type,
  $splunk_home = $splunk::splunk_home,
  $service = $splunk::service
) {
  case $::osfamily {
    /^[Ww]indows$/: {
      notice("enable => ${service}[enable]")
      notice("ensure => ${service}[ensure]")
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
      notice("enable => ${service}[enable]")
      notice("ensure => ${service}[ensure]")
      if $service[ensure] == undef {
        service { 'splunk':
          enable  => $service[enable],
        }
      } else {
        service { 'splunk':
          ensure => $service[ensure],
          enable => $service[enable],
        }
      }
    }
  }
}

