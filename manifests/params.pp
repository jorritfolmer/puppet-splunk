# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::params (
) {
  $admin                        = undef
  $auth                         = {
    'type'                      => 'Splunk',
    'saml_idptype'              => undef,
    'saml_idpurl'               => undef,
    'saml_signauthnrequest'     => true,
    'saml_signedassertion'      => true,
    'saml_signaturealgorithm'   => 'RSA-SHA256',
    'saml_fqdn'                 => undef,
    'saml_entityid'             => undef,
    'ldap_anonymousreferrals'   => undef,
    'ldap_binddn'               => undef,
    'ldap_binddnpassword'       => undef,
    'ldap_groupnameattribute'   => 'cn',
    'ldap_groupmemberattribute' => 'member',
    'ldap_groupbasedn'          => undef,
    'ldap_groupbasefilter'      => '(objectclass=group)',
    'ldap_host'                 => undef,
    'ldap_nestedgroups'         => undef,
    'ldap_realnameattribute'    => 'cn',
    'ldap_sslenabled'           => 1,
    'ldap_userbasedn'           => undef,
    'ldap_userbasefilter'       => '(objectclass=user)',
    'ldap_usernameattribute'    => 'sAMAccountName',
  }
  $ciphersuite_intermediate     = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'
  $ciphersuite_modern           = 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES256-GCM-SHA384:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK'
  $clustering                   = { }
  $dhparamsize_intermediate     = 2048
  $dhparamsize_modern           = 2048
  $ds                           = undef
  $ds_intermediate              = undef
  $dontruncmds  = false
  $ecdhcurvename_intermediate   = 'secp384r1'
  $ecdhcurvename_modern         = 'secp384r1'
  $httpport                     = undef
  $inputport                    = undef
  $kvstoreport                  = undef
  $lm                           = undef
  $maxbackupindex               = 1
  $maxfilesize                  = 10000000
  $maxkbps                      = undef
  $mgmthostport                 = undef
  $minfreespace = undef
  $package_source               = undef
  $pass4symmkey = 'changeme'
  $phonehomeintervalinsec = 60
  $pool_suggestion = undef
  $outputs                      = undef
  $replication_port = 9887
  $repositorylocation = undef
  $requireclientcert            = undef
  $reuse_puppet_certs           = true
  $rolemap = {
    'admin'     => 'Domain Admins',
    'power'     => 'Power Users',
    'user'      => 'Domain Users',
  }
  # set to some string instead of undef to prevent 'Missing title' errors in Puppet 4.x
  $searchpeers  = 'empty'
  $secret       = undef
  $service      = {
    enable => true,
    ensure => undef,
  }
  $shclustering = { }
  $splunk_os_user               = undef
  $splunk_os_group              = undef
  $splunk_bindip                = undef
  $splunk_db                    = undef
  $sslcompatibility             = 'modern'
  $sslversions_modern           = 'tls1.1, tls1.2'
  $sslversions_intermediate     = '*,-ssl2'
  $sslcertpath                  = 'certs/s2s.pem'
  $sslrootcapath                = 'certs/ca.crt'
  $sslpassword                  = undef
  $sslverifyservercert          = undef
  $tcpout                       = undef
  $type                         = undef
  $use_ack      = false
  $version      = undef
  $webssl                       = true
}

