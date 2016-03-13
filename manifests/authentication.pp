# vim: ts=2 sw=2 et
class splunk::authentication
(
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::splunk_os_user,
  $auth = $splunk::auth,
  $rolemap = $splunk::rolemap
){
  $splunk_app_name = 'puppet_common_auth'
  case $auth['authtype'] {
    'Splunk':    {
      file {"${splunk_home}/etc/apps/${splunk_app_name}_ldap_base":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
      file {"${splunk_home}/etc/apps/${splunk_app_name}_saml_base":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
    }

    'SAML':         {
      case $auth['saml_idptype'] {
        'ADFS':     {
          $attributequerysoappassword = 'unimportant'
          $attributequerysoapusername = 'unimportant'
          $entityid                   = $::fqdn
          $idpattributequeryurl       = $auth['saml_idpurl']
          $idpslourl                  = "${auth['saml_idpurl']}?wa=wsignout1.0"
          $idpssourl                  = $auth['saml_idpurl']
          $idpcertpath                = "${splunk_home}/etc/auth/idpcert.crt"
          # sending signed AuthnRequests from Splunk to ADFS needs to be
          # disabled, otherwise the EventLog will greet you with erorrs like
          # ID6027: Enveloped Signature Transform cannot be the last transform
          # in the chain.
          $signauthnrequest           = false
          # luckily, Splunk is able to process incoming signed assertions,
          # through, on the ADFS side claim encryption needs to be disabled
          $signedassertion            = true
        }
        default:    {
          fail 'Unsupported Identity Provider' }
      }
      file {"${splunk_home}/etc/apps/${splunk_app_name}_ldap_base":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      } ->
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_saml_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_saml_base/local",
        "${splunk_home}/etc/apps/${splunk_app_name}_saml_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_user,
        mode   => '0700',
      } ->
      file { "${splunk_home}/etc/apps/${splunk_app_name}_saml_base/local/authentication.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        mode    => '0600',
        content => template("splunk/${splunk_app_name}_saml_base/local/authentication.conf"),
      }

    }
    'LDAP':      {
      file {"${splunk_home}/etc/apps/${splunk_app_name}_saml_base":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      } ->
      file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base/local",
        "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_user,
        mode   => '0700',
      } ->
      file { "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base/local/authentication.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_user,
        mode    => '0600',
        content => template("splunk/${splunk_app_name}_ldap_base/local/authentication.conf"),
      }
    }
  }
}
