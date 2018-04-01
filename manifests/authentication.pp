# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::authentication
(
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $auth = $splunk::auth,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
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
      $auth_defaults = $splunk::params::auth
      case $auth['saml_idptype'] {
        'ADFS':     {
          $entityid                   = $::fqdn
          $idpattributequeryurl       = $auth['saml_idpurl']
          $idpslourl                  = "${auth['saml_idpurl']}?wa=wsignout1.0"
          $idpssourl                  = $auth['saml_idpurl']
          # other parameters are set in the erb template
        }
        default:    {
          fail 'Unsupported Identity Provider' }
      }
      file {"${splunk_home}/etc/apps/${splunk_app_name}_ldap_base":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
      -> file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_saml_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_saml_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_saml_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_group,
        mode   => $splunk_dir_mode,
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_saml_base/${splunk_app_precedence_dir}/authentication.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_group,
        mode    => $splunk_file_mode,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_saml_base/local/authentication.conf"),
      }

    }
    'LDAP':      {
      $auth_defaults = $splunk::params::auth
      file {"${splunk_home}/etc/apps/${splunk_app_name}_saml_base":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
      -> file { [
        "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base",
        "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base/${splunk_app_precedence_dir}",
        "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base/metadata",]:
        ensure => directory,
        owner  => $splunk_os_user,
        group  => $splunk_os_group,
        mode   => $splunk_dir_mode,
      }
      -> file { "${splunk_home}/etc/apps/${splunk_app_name}_ldap_base/${splunk_app_precedence_dir}/authentication.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_group,
        mode    => $splunk_file_mode,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_app_name}_ldap_base/local/authentication.conf"),
      }
    }
    default: {
    }
  }
}
