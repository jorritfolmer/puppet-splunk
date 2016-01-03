# vim: ts=2 sw=2 et
#
# == Class: splunk
#
# The Splunk class takes are of installing and configuring a Splunk instance
# based on the provided parameters. 
#
# === Parameters
#
# [*type*]
#   Optional. When omitted it installs the Splunk server type.
#   Use type => "uf" if you want to have a Splunk Universal Forwarder.
#
# [*httpport*]
#   Optional. When omitted, it will not start Splunk web.
#   Set httpport => 8000 if you do want to have Splunk web available.
#
# [*kvstoreport*]
#   Optional. When omitted, it will not start Mongodb.
#   Set kvstoreport => 8191 if you do want to have KVstore available.
#
# [*inputport*]
#   Optional. When omitted, it will not start an Splunk2Splunk listener.
#   Set kvstoreport => 9997 if you do want to use this instance as an indexer.
#
# [*tcpout*]
#   Optional. When omitted, it will not forward events to a Splunk indexer.
#   Set tcpout => 'splunk-idx1.internal.corp.tld:9997' if you do want to
#   forward events to a Splunk indexer. 
#
# [*splunk_os_user*]
#   Optional. Run the Splunk instance as this user. By default
#   Splunk/Splunkforwarder will run as user "splunk".
#
# [*lm*]
#   Optional. Used to point to a Splunk license manager.
#
# [*ds*]
#   Optional. Used to point to a Splunk deployment server
#
# [*sslcompatibility*]
#   Optional. Used to configure the SSL compatibility level as defined by
#   Mozilla Labs.  When omitted it will use "modern" compatibility. Set to
#   "intermediate" or "old" if you have older Splunk forwarders or clients
#
# [*admin*]
#    Optional. Used to create a local admin user with predefined hash, full
#    name and email This is a hash with 3 members: hash, fn, email.
# 
# [*service]
#    Optional. Used to manage the running and startup state of the
#    Splunk/Splunkforwarder service. This is a hash with 2 members: ensure, enable.
#
# [*useACK*]
#    Optional. Used to enable indexer acknowledgememt.
#
# [*ds_intermediate*]
#    Optional. Used to create a deployment server that itself is a deployment
#    client to a main deployment server

class splunk (
  $type         = $splunk::params::type,
  $splunk_os_user   = $splunk::params::splunk_os_user,
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
  $httpport       = $splunk::params::httpport,
  $kvstoreport       = $splunk::params::kvstoreport,
  $tcpout       = $splunk::params::tcpout,
  $searchpeers = $splunk::params::searchpeers,
  $admin = $splunk::params::admin,
  $clustering   = $splunk::params::clustering,
  $service      = $splunk::params::service,
  $useACK       = $splunk::params::useACK,
  $ds_intermediate = $splunk::params::ds_intemediate,
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
  include splunk::web
  include splunk::server::ssl
  include splunk::server::license
  include splunk::server::kvstore
  include splunk::server::clustering
  include splunk::splunk_launch
  include splunk::certs::s2s
  include splunk::distsearch
  include splunk::deploymentclient
  include splunk::passwd
  include splunk::service
}

# ISSUES
# 1) 10-18-2015 17:04:22.364 +0200 WARN  main - The hard fd limit is lower than
# the recommended value. The hard limit is '4096' The recommended value is
# '64000'.

