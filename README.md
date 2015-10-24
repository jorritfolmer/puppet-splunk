# Puppet module to create a Splunk cluster

This module installs Splunk servers according with the following best practices:

1) Splunk runs as user "splunk"
2) No services are listening by default except the bare minimum (8089/tcp)
2) TLSv1.1 and TLSv1.2 are enabled by default
3) Perfect Forward Secrecy (PFS) using Elliptic curve Diffie-Hellman (ECDH)
4) Ciphers are set to [modern compatibility](https://wiki.mozilla.org/Security/Server_Side_TLS)

## Examples

### Example 1: Minimal Splunk instance to use as deployment, license server or both:

```puppet
  class { 'splunk_cluster':
    httpport     => 8000,
  }
```

### Example 2: A single standalone Splunk instance that you can use to index and search:

```puppet
  class { 'splunk_cluster':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
```

## Compatibility

Requires Splunk and Splunkforwarders >= 6.2.0
