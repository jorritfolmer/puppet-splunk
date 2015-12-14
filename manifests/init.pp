# vim: ts=2 sw=2 et
class splunk (
  $type         = $splunk::params::type,
  $splunk_os_user   = $splunk::params::splunk_os_user,
  $lm           = $splunk::params::lm,
  $ds           = $splunk::params::ds,
  $sh           = $splunk::params::sh,
  $ciphers      = $splunk::params::ciphers,
  $sslversions  = $splunk::params::sslversions,
  $dhparamsize  = $splunk::params::dhparamsize,
  $ecdhcurvename = $splunk::params::ecdhcurvename,
  $inputport    = $splunk::params::inputport,
  $httpport       = $splunk::params::httpport, 
  $kvstoreport       = $splunk::params::kvstoreport, 
  $tcpout       = $splunk::params::tcpout,
  $searchpeers = $splunk::params::searchpeers,
  $admin = $splunk::params::admin,
  ) inherits splunk::params {

  if $type == 'uf' {
    $splunk_home = '/opt/splunkforwarder'
    $package = 'splunkforwarder'
  } else {
    $splunk_home = '/opt/splunk'
    $package = 'splunk'
  }

  include splunk::installed
  include splunk::inputs
  include splunk::outputs
  include splunk::web
  include splunk::server::ssl
  include splunk::server::license
  include splunk::server::kvstore
  include splunk::splunk_launch
  include splunk::certs::s2s
  include splunk::distsearch
  include splunk::deploymentclient
  include splunk::passwd
}

# ISSUES
# 1) 10-18-2015 17:04:22.364 +0200 WARN  main - The hard fd limit is lower than the recommended value. The hard limit is '4096' The recommended value is '64000'.

