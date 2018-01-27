# vim: ts=2 sw=2 et
class splunk::params (
) {
  $type           = undef
  $package_source = undef
  $splunk_os_user = undef
  $splunk_os_group = undef
  $splunk_bindip  = undef
  $splunk_db      = undef
  $lm             = undef
  $ds             = undef
  $inputport      = undef
  $outputs        = undef
  $webssl         = true
  $sslcompatibility = 'modern'
  $sslversions_modern = 'tls1.1, tls1.2'
  $ciphersuite_modern = 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES256-GCM-SHA384:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK'
  $dhparamsize_modern = 2048
  $ecdhcurvename_modern = 'secp384r1'
  $sslversions_intermediate = '*,-ssl2'
  $ciphersuite_intermediate = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'
  $dhparamsize_intermediate = 2048
  $ecdhcurvename_intermediate = 'secp384r1'
  $requireclientcert = undef
  $reuse_puppet_certs = true
  $sslcertpath   = 'certs/s2s.pem'
  $sslrootcapath = 'certs/ca.crt'
  $httpport     = undef
  $kvstoreport = undef
  $mgmthostport = undef
  $tcpout      = undef
  # set to some string instead of undef to prevent 'Missing title' errors in Puppet 4.x
  $searchpeers = 'empty'
  $admin       = undef
  $clustering  = { }
  $replication_port = 9887
  $shclustering  = { }
  $service     = {
    enable => true,
    ensure => undef,
  }
  $use_ack      = false
  $ds_intermediate = undef
  $phonehomeintervalinsec = 60
  $repositorylocation = undef
  $version     = undef
  $auth                         = {
    'type'                      => 'Splunk',
    'saml_idptype'              => undef,
    'saml_idpurl'               => undef,
    'ldap_host'                 => undef,
    'ldap_binddn'               => undef,
    'ldap_binddnpassword'       => undef,
    'ldap_sslenabled'           => 1,
    'ldap_userbasedn'           => undef,
    'ldap_groupbasedn'          => undef,
    'ldap_usernameattribute'    => 'sAMAccountName',
    'ldap_realnameattribute'    => 'cn',
    'ldap_groupnameattribute'   => 'cn',
    'ldap_groupmemberattribute' => 'member',
    'ldap_nestedgroups'         => undef,
  }
  $rolemap = {
    'admin'     => 'Domain Admins',
    'power'     => 'Power Users',
    'user'      => 'Domain Users',
  }
  $dontruncmds = false
  $minfreespace = undef
  $pass4symmkey = 'changeme'
  $secret = undef
}

