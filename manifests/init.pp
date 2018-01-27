# vim: ts=2 sw=2 et
#
# == Class: splunk
#
# The Splunk class takes are of installing and configuring a Splunk instance
# based on the provided parameters. 

class splunk (
  $type                       = $splunk::params::type,
  $package_source             = $splunk::params::package_source,
  $splunk_os_user             = $splunk::params::splunk_os_user,
  $splunk_os_group            = $splunk::params::splunk_os_group,
  $splunk_bindip              = $splunk::params::splunk_bindip,
  $splunk_db                  = $splunk::params::splunk_db,
  $lm                         = $splunk::params::lm,
  $ds                         = $splunk::params::ds,
  $sslcompatibility           = $splunk::params::sslcompatibility,
  $ciphersuite_modern         = $splunk::params::ciphersuite_modern,
  $sslversions_modern         = $splunk::params::sslversions_modern,
  $dhparamsize_modern         = $splunk::params::dhparamsize_modern,
  $ecdhcurvename_modern       = $splunk::params::ecdhcurvename_modern,
  $ciphersuite_intermediate   = $splunk::params::ciphersuite_intermediate,
  $sslversions_intermediate   = $splunk::params::sslversions_intermediate,
  $dhparamsize_intermediate   = $splunk::params::dhparamsize_intermediate,
  $ecdhcurvename_intermediate = $splunk::params::ecdhcurvename_intermediate,
  $requireclientcert          = $splunk::params::requireclientcert,
  $reuse_puppet_certs         = $splunk::params::reuse_puppet_certs,
  $sslcertpath                = $splunk::params::sslcertpath,
  $sslrootcapath              = $splunk::params::sslrootcapath,
  $inputport                  = $splunk::params::inputport,
  $httpport                   = $splunk::params::httpport,
  $kvstoreport                = $splunk::params::kvstoreport,
  $mgmthostport               = $splunk::params::mgmthostport,
  $tcpout                     = $splunk::params::tcpout,
  $searchpeers                = $splunk::params::searchpeers,
  $admin                      = $splunk::params::admin,
  $clustering                 = $splunk::params::clustering,
  $replication_port           = $splunk::params::replication_port,
  $shclustering               = $splunk::params::shclustering,
  $service                    = $splunk::params::service,
  $use_ack                    = $splunk::params::use_ack,
  $ds_intermediate            = $splunk::params::ds_intermediate,
  $repositorylocation         = $splunk::params::repositorylocation,
  $version                    = $splunk::params::version,
  $auth                       = $splunk::params::auth,
  $rolemap                    = $splunk::params::rolemap,
  $dontruncmds                = $splunk::params::dontruncmds,
  $pass4symmkey               = $splunk::params::pass4symmkey,
  $minfreespace               = $splunk::params::minfreespace,
  $phonehomeintervalinsec     = $splunk::params::phonehomeintervalinsec,
  $secret                     = $splunk::params::secret
  ) inherits splunk::params {

  case $::osfamily {
    /^[Ww]indows$/: {
      if $type == 'uf' {
        $splunk_home = 'c:/program files/splunkuniversalforwarder'
        $package = 'UniversalForwarder'
      } else {
        $splunk_home = 'c:/program files/splunk'
        $package = 'Splunk Enterprise'
      }
      if $splunk_os_user == undef {
        $real_splunk_os_user = 'S-1-5-18'
      }
      if $splunk_os_group == undef {
        $real_splunk_os_group = 'Administrators'
      }
      $real_splunk_dir_mode = '0775'
      $real_splunk_file_mode = '0774'
    }
    default: {
      if $type == 'uf' {
        $splunk_home = '/opt/splunkforwarder'
        $package = 'splunkforwarder'
      } else {
        $splunk_home = '/opt/splunk'
        $package = 'splunk'
      }
      if $splunk_os_user == undef {
        $real_splunk_os_user = 'splunk'
      }
      if $splunk_os_group == undef {
        $real_splunk_os_group = 'splunk'
      }
      $real_splunk_dir_mode = '0700'
      $real_splunk_file_mode = '0600'
    }
  }

  case $sslcompatibility {
    'modern':            {
      $ciphersuite   = $ciphersuite_modern
      $sslversions   = $sslversions_modern
      $dhparamsize   = $dhparamsize_modern
      $ecdhcurvename = $ecdhcurvename_modern }
    'intermediate':      {
      $ciphersuite   = $ciphersuite_intermediate
      $sslversions   = $sslversions_intermediate
      $dhparamsize   = $dhparamsize_intermediate
      $ecdhcurvename = undef }
    default: {
      $ciphersuite   = undef
      $sslversions   = undef
      $dhparamsize   = undef
      $ecdhcurvename = undef }
  }

  if $shclustering[mode] == 'searchhead' {
    # for SHC nodes we only place bootstrap config, so make
    # sure that staging directories end up using default dir
    # instead of local, and don't replace any existing config 
    $splunk_app_precedence_dir = 'default'
    $splunk_app_replace = false
  } else {
    $splunk_app_precedence_dir = 'local'
    $splunk_app_replace = true
  }

  include splunk::installed
  include splunk::inputs
  include splunk::outputs
  include splunk::certs::s2s
  include splunk::web
  include splunk::server::general
  include splunk::server::ssl
  include splunk::server::license
  include splunk::server::kvstore
  include splunk::server::clustering
  include splunk::server::shclustering
  include splunk::server::diskusage
  include splunk::splunk_launch
  include splunk::deploymentclient
  include splunk::distsearch
  include splunk::passwd
  include splunk::authentication
  include splunk::secret
  include splunk::mgmtport
  include splunk::first_time_run
  include splunk::service

  # make sure classes are properly ordered and contained
  anchor { 'splunk_first': }
  -> Class['splunk::installed']
  -> Class['splunk::inputs']
  -> Class['splunk::outputs']
  -> Class['splunk::certs::s2s']
  -> Class['splunk::web']
  -> Class['splunk::server::general']
  -> Class['splunk::server::ssl']
  -> Class['splunk::server::license']
  -> Class['splunk::server::kvstore']
  -> Class['splunk::server::clustering']
  -> Class['splunk::server::shclustering']
  -> Class['splunk::server::diskusage']
  -> Class['splunk::splunk_launch']
  -> Class['splunk::deploymentclient']
  -> Class['splunk::distsearch']
  -> Class['splunk::passwd']
  -> Class['splunk::authentication']
  -> Class['splunk::secret']
  -> Class['splunk::mgmtport']
  -> Class['splunk::first_time_run']
  -> Class['splunk::service']
  -> splunk::addsearchpeers { $searchpeers: }
  anchor { 'splunk_last': }
}

