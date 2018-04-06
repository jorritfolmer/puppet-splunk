# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

define splunk::addsearchpeers {
  if $title != 'empty' {
    $package = $splunk::package
    $splunk_home = $splunk::splunk_home
    $admin = $splunk::admin
    $dontruncmds = $splunk::dontruncmds

    if $admin[pass] == undef {
      fail('Plaintext admin password is not set but required for adding search peers')
    } elsif $dontruncmds == true {
      notice('Skipping splunk add search-server due to $dontruncmds=true')
    } else {
      $adminpass = $admin[pass]
      exec { "splunk add search-server ${title}":
        command     => "splunk add search-server -host ${title} -auth admin:${adminpass} -remoteUsername admin -remotePassword ${adminpass} && touch ${splunk_home}/etc/auth/distServerKeys/${title}.done",
        path        => ["${splunk_home}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
        environment => ["SPLUNK_HOME=${splunk_home}"],
        creates     => [
          "${splunk_home}/etc/auth/distServerKeys/${title}.done",
        ],
        logoutput   => true,
      }
    }
  }
}
