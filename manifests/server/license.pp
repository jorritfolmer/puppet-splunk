# vim: ts=2 sw=2 et
class splunk::server::license (
  $lm = $splunk::lm,
  $splunk_home = $splunk::splunk_home
){
  if $lm == undef {
    augeas { "${splunk_home}/etc/system/local/server.conf/license":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/server.conf",
      changes => [
        'rm license/master_uri',
      ],
    }
  } else {
    augeas { "${splunk_home}/etc/system/local/server.conf/license":
      lens    => 'Puppet.lns',
      incl    => "${splunk_home}/etc/system/local/server.conf",
      changes => [
        "set license/master_uri https://${lm}",
      ],
    }
  }
}

