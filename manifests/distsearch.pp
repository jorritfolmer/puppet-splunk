# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::distsearch (
  $searchpeers = $splunk::searchpeers,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_home = $splunk::splunk_home
){
  if $searchpeers == undef {
    file { "${splunk_home}/etc/system/local/distsearch.conf":
      ensure  => 'absent',
    }
  } else {
    # do nothing, because we use $SPLUNK_HOME/bin/splunk add search-server
  }
}
