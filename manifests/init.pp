# vim: ts=2 sw=2 et
class splunk_cluster (
  $splunk_home  = $splunk_cluster::params::splunk_home,
  $splunk_os_user   = $splunk_cluster::params::splunk_os_user,
  $lm           = $splunk_cluster::params::lm,
  $ds           = $splunk_cluster::params::ds,
  $sh           = $splunk_cluster::params::sh,
  $ciphers      = $splunk_cluster::params::ciphers,
  $sslversions  = $splunk_cluster::params::sslversions,
  $dhparamsize  = $splunk_cluster::params::dhparamsize,
  $ecdhcurvename = $splunk_cluster::params::ecdhcurvename,
  $inputport    = $splunk_cluster::params::inputport,
  $httpport       = $splunk_cluster::params::httpport, 
  $kvstoreport       = $splunk_cluster::params::kvstoreport, 
  $tcpout       = $splunk_cluster::params::tcpout,
  $searchpeers = $splunk_cluster::params::searchpeers,
  $adminpass = $splunk_cluster::params::searchpeers,
  ) inherits splunk_cluster::params {

  include splunk_cluster::installed
  include splunk_cluster::inputs
  include splunk_cluster::outputs
  include splunk_cluster::web
  include splunk_cluster::server::ssl
  include splunk_cluster::server::license
  include splunk_cluster::server::kvstore
  include splunk_cluster::splunk_launch
  include splunk_cluster::certs::s2s
  include splunk_cluster::distsearch
  include splunk_cluster::deploymentclient
}

# ISSUES
# 1) 10-18-2015 17:04:22.364 +0200 WARN  main - The hard fd limit is lower than the recommended value. The hard limit is '4096' The recommended value is '64000'.

