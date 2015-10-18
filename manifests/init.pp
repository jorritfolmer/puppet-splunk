# vim: ts=2 sw=2 et
class splunk_cluster (
  $splunk_home  = $splunk_cluster::params::splunk_home,
  $lm           = $splunk_cluster::params::lm,
  $ds           = $splunk_cluster::params::ds,
  $sh           = $splunk_cluster::params::sh,
  $indexers     = $splunk_cluster::params::indexers,
  $inputport    = $splunk_cluster::params::inputport,
  $outputs      = $splunk_cluster::params::outputs,
  $ciphers      = $splunk_cluster::params::ciphers,
  $sslversions  = $splunk_cluster::params::sslversions,
  ) inherits splunk_cluster::params {

  include splunk_cluster::installed
  include splunk_cluster::inputs
  include splunk_cluster::web
  include splunk_cluster::server::ssl
  include splunk_cluster::server::license
}

# ISSUES
# 1) 10-18-2015 17:04:22.364 +0200 WARN  main - The hard fd limit is lower than the recommended value. The hard limit is '4096' The recommended value is '64000'.
# 2) SSL modern compatibility ciphers

