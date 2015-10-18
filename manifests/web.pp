# vim: ts=2 sw=2 et
class splunk_cluster::web ( 
  $ciphersuite = $splunk_cluster::ciphersuite,
  $sslversions = $splunk_cluster::sslversions,
){
  augeas { '/opt/splunk/etc/system/local/web.conf':
    require => Class['splunk_cluster::installed'],
    lens    => 'Puppet.lns',
    incl    => '/opt/splunk/etc/system/local/web.conf',
    changes => [
      "set settings/enableSplunkWebSSL true",
      "set settings/sslVersions $sslversions",
      "set settings/cipherSuite $ciphersuite",
    ];
  }
}
