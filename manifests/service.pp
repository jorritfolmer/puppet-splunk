# vim: ts=2 sw=2 et
class splunk::service (
  $package = $splunk::package,
  $splunk_home = $splunk::splunk_home,
  $service = $splunk::service
) {
  if $service[ensure] == undef {
    service { 'splunk':
      enable  => $service[enable],
      require => [
        Class['splunk::installed'],
        Class['splunk::server::ssl'],
      ],
    }
  } else {
    service { 'splunk':
      ensure  => $service[ensure],
      enable  => $service[enable],
      require => [
        Class['splunk::installed'],
        Class['splunk::server::ssl'],
        Class['splunk::passwd'],
      ],
    }
  }
}
