# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::loglocal (
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $maxbackupindex = $splunk::maxbackupindex,
  $maxfilesize = $splunk::maxfilesize
){
  file { "${splunk_home}/etc/log-local.cfg":
    ensure  => present,
    content => template('splunk/log-local/log-local.cfg'),
    owner   => $splunk_os_user,
    group   => $splunk_os_group,
    mode    => $splunk_file_mode,
    replace => false
  }
}

