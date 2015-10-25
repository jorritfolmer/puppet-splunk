# Puppet module to create Splunk topologies

## Principles

This Puppet module installs and configures Splunk servers with the following principles in mind:

1. Splunk above Puppet

    Puppet is only used to configure the running skeleton of a Splunk constellation. It tries to keep away from Splunk administration as much as possible. Why deploy Splunk apps through Puppet if you can use Splunk's multi-platform deployment server?

2. Power to the Splunkers

    A Splunk installation should typically not be administered by the IT or IT-infra teams, since it is often used in an audit context.

3. Secure by default
    - Splunk runs as user "splunk"
    - No services are listening by default except the bare minimum (8089/tcp)
    - TLSv1.1 and TLSv1.2 are enabled by default
    - Perfect Forward Secrecy (PFS) using Elliptic curve Diffie-Hellman (ECDH)
    - Ciphers are set to [modern compatibility](https://wiki.mozilla.org/Security/Server_Side_TLS)

4. Supports any topology

    Single server? Redundant multi-site clustering? Heavy forwarder in a DMZ?

## Installation

TODO

## Usage

Currently implemented: distributed search.
TODO: index clustering.
TODO: search head clustering.

### Example 1: 

A single standalone Splunk instance that you can use to index and search, for example with the trial license:

```puppet
  class { 'splunk_cluster':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
```

### Example 2: 

One deployment/license server, one search head, and two indexers:

```puppet
node 'splunk-ds.internal.corp.tld' {
  class { 'splunk_cluster':
    adminpass    => 'secret',
    httpport     => 8000,
    tcpout       => [
      'splunk-idx1.internal.corp.tld:9997', 
      'splunk-idx2.internal.corp.tld:9997',
    ],
  }
}

node 'splunk-sh.internal.corp.tld' {
  class { 'splunk_cluster':
    adminpass    => 'secret',
    httpport     => 8000,
    kvstoreport  => 8191,
    lm           => 'splunk-ds.internal.corp.tld:8089',
    ds           => 'splunk-ds.internal.corp.tld:8089',
    tcpout       => [
      'splunk-idx1.internal.corp.tld:9997', 
      'splunk-idx2.internal.corp.tld:9997',
    ],
    searchpeers  => [
      'splunk-idx1.internal.corp.tld:8089', 
      'splunk-idx2.internal.corp.tld:8089',
    ],
  }
}

node 'splunk-idx1.internal.corp.tld', 'splunk-idx2.internal.corp.tld' {
  class { 'splunk_cluster':
    adminpass    => 'secret',
    httpport     => 8000,
    inputport    => 9997,
    lm           => 'splunk-ds.internal.corp.tld:8089',
    ds           => 'splunk-ds.internal.corp.tld:8089',
  }
}
```

### Example 3: 

One deployment/license server, one search head, and an indexing cluster:

TODO

## Parameters

TODO

```
  $splunk_home  
  $splunk_os_user
  $lm           
  $ds           
  $sh           
  $ciphers      
  $sslversions  
  $dhparamsize  
  $ecdhcurvename 
  $inputport    
  $httpport    
  $kvstoreport
  $tcpout     
  $searchpeers 
  $adminpass     
  $compatibility TODO
```

## Compatibility

Requires Splunk and Splunkforwarders >= 6.2.0.
However, if you still have versions < 6.2, pass `compatibility => 'intermediate'`
