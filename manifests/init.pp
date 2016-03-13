# vim: ts=2 sw=2 et
#
# == Class: splunk
#
# The Splunk class takes are of installing and configuring a Splunk instance
# based on the provided parameters. 

class splunk (
  $type         = $splunk::params::type,
  $splunk_os_user   = $splunk::params::splunk_os_user,
  $splunk_bindip    = $splunk::params::splunk_bindip,
  $lm           = $splunk::params::lm,
  $ds           = $splunk::params::ds,
  $sslcompatibility = $splunk::params::sslcompatibility,
  $ciphersuite_modern  = $splunk::params::ciphersuite_modern,
  $sslversions_modern  = $splunk::params::sslversions_modern,
  $dhparamsize_modern  = $splunk::params::dhparamsize_modern,
  $ecdhcurvename_modern = $splunk::params::ecdhcurvename_modern,
  $ciphersuite_intermediate  = $splunk::params::ciphersuite_intermediate,
  $sslversions_intermediate  = $splunk::params::sslversions_intermediate,
  $dhparamsize_intermediate  = $splunk::params::dhparamsize_intermediate,
  $ecdhcurvename_intermediate = $splunk::params::ecdhcurvename_intermediate,
  $inputport    = $splunk::params::inputport,
  $httpport     = $splunk::params::httpport,
  $kvstoreport  = $splunk::params::kvstoreport,
  $tcpout       = $splunk::params::tcpout,
  $searchpeers  = $splunk::params::searchpeers,
  $admin        = $splunk::params::admin,
  $clustering   = $splunk::params::clustering,
  $service      = $splunk::params::service,
  $useACK       = $splunk::params::useACK,
  $ds_intermediate = $splunk::params::ds_intemediate,
  $version      = $splunk::params::version,
  $auth         = $splunk::params::auth,
  $rolemap      = $splunk::params::rolemap,
  $dontruncmds  = $splunk::params::dontruncmds,
  $pass4symmkey  = $splunk::params::pass4symmkey,
  $phonehomeintervalinsec = $splunk::params::phonehomeintervalinsec
  ) inherits splunk::params {

  if $type == 'uf' {
    $splunk_home = '/opt/splunkforwarder'
    $package = 'splunkforwarder'
  } else {
    $splunk_home = '/opt/splunk'
    $package = 'splunk'
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
  include splunk::splunk_launch
  include splunk::deploymentclient
  include splunk::distsearch
  include splunk::passwd
  include splunk::authentication
  include splunk::service

  # make sure classes are properly ordered and contained
  anchor { 'splunk_first': } ->
  Class['splunk::installed'] ->
  Class['splunk::inputs'] ->
  Class['splunk::outputs'] ->
  Class['splunk::certs::s2s'] ->
  Class['splunk::web'] ->
  Class['splunk::server::general'] ->
  Class['splunk::server::ssl'] ->
  Class['splunk::server::license'] ->
  Class['splunk::server::kvstore'] ->
  Class['splunk::server::clustering'] ->
  Class['splunk::splunk_launch'] ->
  Class['splunk::deploymentclient'] ->
  Class['splunk::distsearch'] ->
  Class['splunk::passwd'] ->
  Class['splunk::authentication'] ->
  Class['splunk::service'] ->
  splunk::addsearchpeers { $searchpeers: }
  anchor { 'splunk_last': }

}

# ISSUES
# 1) 10-18-2015 17:04:22.364 +0200 WARN  main - The hard fd limit is lower than
# the recommended value. The hard limit is '4096' The recommended value is
# '64000'.

