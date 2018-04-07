# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#

class splunk::passwd (
  $admin = $splunk::admin,
  $splunk_home = $splunk::splunk_home,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode
){
  case $::osfamily {
    /^[Ww]indows$/: {
      notify {'Setting admin password not supported on Windows':}
      warning('Setting admin password not supported on Windows')
    }
    default: {
      if $admin != undef {
        if $admin[hash] != undef {
          $hash  = $admin[hash]
          $fn    = $admin[fn] ? {
            undef   => '',
            default => $admin[fn]
          }
          $email = $admin[email] ? {
            undef   => '',
            default => $admin[email]
          }
          file { "${splunk_home}/etc/passwd":
            ensure  => present,
            owner   => $splunk_os_user,
            group   => $splunk_os_group,
            mode    => $splunk_dir_mode,
            content => ':admin:::',
            replace => 'no',
          }
          -> exec { 'set admin passwd':
            command => "sed -i -e 's#^:admin:.*$#:admin:${hash}::${fn}:admin:${email}::#g' ${splunk_home}/etc/passwd",
            unless  => "grep -qe '^:admin:${hash}' ${splunk_home}/etc/passwd",
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
          }
          -> file { "${splunk_home}/etc/.ui_login":
            ensure  => present,
            owner   => $splunk_os_user,
            group   => $splunk_os_group,
            mode    => $splunk_file_mode,
            content => '',
            replace => 'no',
          }
        }
      }
    }
  }
}

