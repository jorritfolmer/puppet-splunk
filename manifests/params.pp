# vim: ts=2 sw=2 et
class splunk_cluster::params (
) {
  $splunk_home = '/opt/splunk'
  $splunk_os_user = 'splunk'
  $package     = 'splunk'
  $lm          = undef
  $ds          = undef
  $sh          = undef
  $indexers    = undef
  $inputport   = undef
  $outputs     = undef
  $webssl      = true
  $sslversions = '\'tls1.1, tls1.2\''
  $ciphersuite = 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK'
  $dhparamsize = 2048
  $ecdhcurvename = 'secp521r1'
  $httpport     = undef 
  $kvstoreport = undef
  $tcpout      = undef
  $searchpeers = undef
  $adminpass   = undef
}

