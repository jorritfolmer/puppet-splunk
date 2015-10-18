# vim: ts=2 sw=2 et
class splunk_cluster::params (
) {
  $splunk_home = '/opt/splunk'
  $package     = 'splunk'
  $lm          = undef
  $ds          = undef
  $sh          = undef
  $indexers    = undef
  $inputport   = undef
  $outputs     = undef
  $webssl      = true
  $sslversions = '\'tls1.1, tls1.2\''
  $ciphersuite = 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA'
}

# Used Intermediate compatibility ciphersuite from https://wiki.mozilla.org/Security/Server_Side_TLS
# Modern compatibility ciphersuite doesn't work, splunkd.log:
# 10-18-2015 17:26:32.650 +0200 WARN  HttpListener - Socket error from 127.0.0.1 while idling: error:1408A0C1:SSL routines:ssl3_get_client_hello:no shared cipher


