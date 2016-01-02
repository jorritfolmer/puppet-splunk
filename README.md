# Puppet module to create Splunk topologies

This Puppet module installs and configures Splunk servers and Splunk universal forwarders with the following principles in mind:

## Principles

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

1. SSH to your Puppet master
2. `cd /etc/puppet/modules`
3. `git clone https://github.com/jorritfolmer/puppet-splunk.git`
4  `mv puppet-splunk splunk`
5. Add the `splunk` class to your nodes in /etc/puppet/manifests/site.pp, see below for examples.

## Usage

To give this module a try, you don't necessarily have to setup a Certiticate Authority for the various SSL certificates that Splunk uses.

1. By default Splunk already uses its own CA (1024 bits) that is used to create and sign the certificate for the 8089/tcp management port and 8000/tcp web interface: /opt/splunk/etc/auth/ca.pem. However, since everyone can grab the key from a Splunk trial download, it's an unlikely candidate for real production use.
2. Because there is already a Puppet CA in place, this module reuses the client key (4096 bits) and client certificate signed by the Puppet CA.

### Example 1: 

Define a single standalone Splunk instance that you can use to index and search, for example with the trial license:

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
}
```

### Example 2: 

Define another instance with Splunk universal forwarder. Following principle 1, it connects to the Splunk instance above, where apps, inputs and outputs can be managed and deployed through Forwarder Management.

```puppet
node 'some-server.internal.corp.tld' {
  class { 'splunk':
    type => 'uf',
    ds   => 'splunk-server.internal.corp.tld:8089',
  }
}
```

### Example 3: 

One deployment/license server, one search head, and two indexers:

```puppet
node 'splunk-ds.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      # Set the admin password to changemeagain
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Deployment Server Administrator',
      email      => 'changemeagain@example.com',
    },
    # Enable the web server
    httpport     => 8000,
    # Use the best-practice to forward all local events to the indexers
    tcpout       => [
      'splunk-idx1.internal.corp.tld:9997', 
      'splunk-idx2.internal.corp.tld:9997',
    ],
  }
}

node 'splunk-sh.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      # In this case, a plaintext password is also needed to join the
      # searchpeers to this search head
      pass       => 'changemeagain',
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Search head Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    kvstoreport  => 8191,
    # Use a License Master and Deployment Server
    lm           => 'splunk-ds.internal.corp.tld:8089',
    ds           => 'splunk-ds.internal.corp.tld:8089',
    tcpout       => [ 
      'splunk-idx1.internal.corp.tld:9997', 
      'splunk-idx2.internal.corp.tld:9997', ],
    # Use these search peers
    searchpeers  => [ 
      'splunk-idx1.internal.corp.tld:8089', 
      'splunk-idx2.internal.corp.tld:8089', ],
  }
}

node 'splunk-idx1.internal.corp.tld', 'splunk-idx2.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Indexer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-ds.internal.corp.tld:8089',
    ds           => 'splunk-ds.internal.corp.tld:8089',
  }
}
```

### Example 4: 

A Splunk indexer cluster consisting of one deployment/license/searchhead server, a cluster master, and two cluster peers.

```puppet
node 'splunk-sh.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Search Head Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    kvstoreport  => 8191,
    tcpout       => [ 'splunk-cidx1.internal.corp.tld:9997', 'splunk-cidx2.internal.corp.tld:9997', ],
    clustering   => {
      mode       => 'searchhead',
      cm         => 'splunk-cm.internal.corp.tld:8089',
    }
  }
}

node 'splunk-cm.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Master Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    tcpout       => [ 'splunk-cidx1.internal.corp.tld:9997', 'splunk-cidx2.internal.corp.tld:9997', ],
    clustering   => {
      mode               => 'master',
      replication_factor => 2,
      search_factor      => 2,
    }
  }
}

node 'splunk-cidx1.internal.corp.tld', 'splunk-cidx2.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    clustering   => {
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.tld:8089',
    }
  }
}
```

## Parameters

TODO

```
  $splunk_home
  $splunk_os_user
  $lm
  $ds
  $sh
  $ciphersuite
  $sslversions
  $dhparamsize
  $ecdhcurvename
  $inputport
  $httpport
  $kvstoreport
  $tcpout
  $searchpeers
  $admin
  $sslcompatibility
  $clustering
```

## Compatibility

Requires Splunk and Splunkforwarders >= 6.2.0.
However, if you still have versions < 6.2 , pass `sslcompatibility => 'intermediate'`
If you have version >= 6.2.0 servers but with stock settings, also pass `sslcompatibility => 'intermediate'` in the universal forwarder declaration, otherwise the SSL connections to the deploymentserver will fail.

