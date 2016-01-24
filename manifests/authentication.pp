# vim: ts=2 sw=2 et
class splunk::authentication
(
  $splunk_home = $splunk::splunk_home,
  $authType = $splunk::authtype,
  $idptype = $splunk::idptype,
  $idpurl = $splunk::idpurl,
  $rolemap_SAML = $splunk::rolemap_SAML,
){
  case $authType {
    'Splunk':    {
      augeas { "${splunk_home}/etc/system/local/authentication.conf SAML":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "${splunk_home}/etc/system/local/authentication.conf",
        changes => [
          'rm authentication/authType',
          'rm authentication/authSettings',
        ],
      }
    }
    'SAML':      {
      case $idptype {
        'ADFS':     {
          $attributeQuerySoapPassword = 'unimportant'
          $attributeQuerySoapUsername = 'unimportant'
          $entityId                   = $::fqdn
          $idpAttributeQueryUrl       = $idpurl
          $idpSLOUrl                  = "${idpurl}?wa=wsignout1.0"
          $idpSSOUrl                  = $idpurl
          $idpCertPath                = "${splunk_home}/etc/auth/idpcert.crt"
          $signAuthnRequest           = false
          $signedAssertion            = true
          $redirectPort               = $splunk::httpport
          $rolemap_SAML_admin         = $rolemap_SAML[admin]
          $rolemap_SAML_power         = $rolemap_SAML[power]
          $rolemap_SAML_user          = $rolemap_SAML[user]
        }        
        default:    {
          fail 'Unsupported Identity Provider' }
      }
      augeas { "${splunk_home}/etc/system/local/authentication.conf SAML":
        require => Class['splunk::installed'],
        lens    => 'Puppet.lns',
        incl    => "${splunk_home}/etc/system/local/authentication.conf",
        changes => [
          'set authentication/authType SAML',
          'set authentication/authSettings saml_settings',
          "set saml_settings/attributeQuerySoapPassword ${attributeQuerySoapPassword}",
          "set saml_settings/attributeQuerySoapUsername ${attributeQuerySoapUsername}",
          "set saml_settings/entityId ${entityId}",
          "set saml_settings/idpAttributeQueryUrl ${idpAttributeQueryUrl}",
          "set saml_settings/idpSLOUrl ${idpSLOUrl}",
          "set saml_settings/idpSSOUrl ${idpSSOUrl}",
          "set saml_settings/idpCertPath ${idpCertPath}",
          "set saml_settings/redirectPort ${redirectPort}",
          "set saml_settings/signAuthnRequest ${signAuthnRequest}",
          "set saml_settings/signedAssertion ${signedAssertion}",
          "set rolemap_SAML/admin '${rolemap_SAML_admin}'",
          "set rolemap_SAML/power '${rolemap_SAML_power}'",
          "set rolemap_SAML/user '${rolemap_SAML_user}'",
        ],
      }
    }
  }
}
