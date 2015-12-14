# vim: ts=2 sw=2 et
class splunk::passwd ( 
  $admin = $splunk::admin,
  $splunk_home = $splunk::splunk_home,
){
  if $admin != undef {
    $hash  = $admin[hash]
    $fn    = $admin[fn]
    $email = $admin[email]
    exec { "sed -i -e 's#^:admin:.*$#:admin:$hash::$fn:admin:$email::#g' $splunk_home/etc/passwd":
      unless  => "grep -qe '^:admin:$hash' $splunk_home/etc/passwd",
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    }
  }
}

