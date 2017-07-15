# Puppet module to deploy Splunk into any imaginable topology on Windows and Linux.

[![Travis CI build status](https://travis-ci.org/jorritfolmer/puppet-splunk.svg?branch=master)](https://travis-ci.org/jorritfolmer/puppet-splunk)

This Puppet module can be used on Windows and Linux to create and arrange the following Splunk instances into simple, distributed or (multisite) clustered topologies:

- Splunk indexers
- Splunk search heads
- Splunk cluster masters
- Splunk search head deployers
- Splunk deployment servers
- Splunk heavy forwarders
- Splunk universal forwarders

It does so with the following principles in mind:

## Principles

1. **Splunk above Puppet.** Puppet is only used to configure the running skeleton of a Splunk constellation. It tries to keep away from Splunk administration as much as possible. For example, why deploy Splunk apps to forwarders through Puppet if you can use Splunk's multi-platform deployment server?
2. **Power to the Splunkers.** A Splunk installation should typically not be administered by the IT or IT-infra teams. This Puppet module should smooth the path to implementing segregation of duties between administrators and watch(wo)men (ISO 27002 12.4.3 or BIR 10.10.3).
3. **Secure by default**.
  - Splunk runs as user splunk instead of root.
  - No services are listening by default except the bare minimum (8089/tcp)
  - TLSv1.1 and TLSv1.2 are enabled by default
  - Perfect Forward Secrecy (PFS) using Elliptic curve Diffie-Hellman (ECDH)
  - Ciphers are set to [modern compatibility](https://wiki.mozilla.org/Security/Server_Side_TLS)
  - Admin password can be set using its SHA512 hash in the Puppet manifests instead of plain-text.
4. **Supports any topology.** Single server? Redundant multi-site clustering? Heavy forwarder in a DMZ?

## Prerequisites

1. A running Puppet master
2. A running repository server with splunk and splunkforwarder packages. See below if you need help setting it up.

## Quick-start

Define a single standalone Splunk instance on Linux that you can use to index and search, for example with the trial license:

![Example 1a](example1.png)

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
}
```

Or define a single standalone Splunk instance on Windows with:

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    package_source => '//dc01/Company/splunk-6.6.1-aeae3fe0c5af-x64-release.msi',
    httpport       => 8000,
    kvstoreport    => 8191,
    inputport      => 9997,
  }
}
```

See the other examples below for more elaborate topologies.


### Splunk YUM repository (Red Hat based)

If you don't already have a local repository server, the quickest way is to install Apache on the Puppet master and have this serve the yum repository.

1. `yum install httpd`
2. `yum install createrepo`
3. `mkdir /var/www/html/splunk`
4. `cd /var/www/html/splunk`
5. download splunk-x.y.x.rpm
6. download splunk-forwarder-x.y.x.rpm
7. `createrepo .`
8. make sure Apache allows directory index listing
9. surf to http://your.repo.server/splunk and check if you get a directory listing

Then add something like this to every node definition in site.pp, and require it from the splunk class so it it evaluated before the splunk class.

```
yumrepo { "splunk":
  baseurl => "http://your.repo.server/splunk",
  descr => "Splunk repo",
  enabled => 1,
  gpgcheck => 0
}
```

### Splunk APT repository (Debian/Ubuntu based)

If you don't already have a local repository server, the quickest way is to install Apache on the Puppet master and have this serve the APT repository.

1. `apt-get install apache2`
2. `apt-get install dpkg-dev`
3. `mkdir /var/www/html/splunk`
4. `cd /var/www/html/splunk`
5. download splunk-x.y.x.deb
6. download splunk-forwarder-x.y.x.deb
7. `dpkg-scanpackages . /dev/null |gzip -c > Packages.gz`
8. make sure Apache allows directory index listing
9. surf to http://your.rhel-repo.server/splunk and check if you get a directory listing

Then add something like this to every node definition in site.pp, and make sure to require these files from the splunk class so they are evaluated before the splunk class. Because the APT repository above isn't signed, puppet won't be able to install splunk or splunkforwarder, except when setting `APT::Get::AllowUnauthenticated` somewhere in `/etc/apt/apt.conf.d/`. You may have to run apt-get update before the Splunk repository is available in apt-get.

```
file { "/etc/apt/apt.conf.d/99allowunsigned":
  ensure => present,
  content => "APT::Get::AllowUnauthenticated "true";\n",
}
file { "/etc/apt/sources.list.d/splunk.list":
  ensure => present,
  content => "deb http://your.apt-repo.server/splunk ./\n",
}
```

### CIFS share with .msi files (Windows based)

For Windows installations just put the .msi Splunk installation files for
Windows on a share that is accessible from all your Windows servers.

1. create a share that can be accessed by all your Windows servers
2. download the relevant Splunk .msi files from the Splunk website into this share
3. specify `package_source` and point to one of these .msi files


## Puppet-Splunk installation

1. SSH to your Puppet master
2. `cd /etc/puppet/modules` or `cd /etc/puppetlabs/code/environments/production/modules`, depending on your Puppet version
3. `puppet module install jorritfolmer-splunk` or `git clone https://github.com/jorritfolmer/puppet-splunk.git; mv puppet-splunk splunk`
4. Create your Splunk topology, see below for examples.

## Usage

To give this module a try, you don't necessarily have to setup a Certiticate Authority for the various SSL certificates that Splunk uses.

By default, this module reuses the Puppet client SSL key (4096 bits) and client certificate, so we can save us the trouble of setting up and maintaining our own certificate authority. 

For quick testing in heterogeneous non-production environments you can revert to using the Splunk provides certs and CA with `reuse_puppet_certs => false`. Or you can point to your own certificates with `sslcertpath` and `sslrootcapath`.

The Splunk module doesn't manage the state of the splunk service, except configure to start Splunk or Splunkforwarder at boot time. However, if you do want Puppet to interfere while performing a cluster rolling restart or an indexer restart, have a look at the `service` parameter. 

### Example 1: 

Define a single standalone Splunk instance that you can use to index and search, for example with the trial license.
This time use the Splunk provided non-production testing certificates instead of reusing the ones signed by the Puppet CA, for example for testing in heterogeneous environments with non-Puppetized Splunk forwarders.

![Example 1b](example1.png)

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    httpport           => 8000,
    kvstoreport        => 8191,
    inputport          => 9997,
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
  }
}
```

To define a standalone Splunk instance running on Windows:

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    package_source     => '//dc01/Company/splunk-6.6.1-aeae3fe0c5af-x64-release.msi',
    httpport           => 8000,
    kvstoreport        => 8191,
    inputport          => 9997,
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
  }
}
```

### Example 2a: 

Extends the example above with a node that will run the Splunk universal forwarder. It uses the first server as Deployment Server (`ds =>`) where apps, inputs and outputs can be managed and deployed through Forwarder Management.

![Example 2](example2.png)

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
}

node 'some-server.internal.corp.tld' {
  class { 'splunk':
    type => 'uf',
    ds   => 'splunk-server.internal.corp.tld:8089',
  }
}
```

The equivalent for Windows environments:

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    package_source => '//dc01/Company/splunk-6.6.1-aeae3fe0c5af-x64-release.msi',
    httpport       => 8000,
    kvstoreport    => 8191,
    inputport      => 9997,
  }
}

node 'some-server.internal.corp.tld' {
  class { 'splunk':
    package_source => '//dc01/Company/splunkforwarder-6.6.1-aeae3fe0c5af-x64-release.msi',
    type           => 'uf',
    ds             => 'splunk-server.internal.corp.tld:8089',
  }
}
```


### Example 2b: 

Almost identical to example 2a, except with some SSL downgrading, not suitable for production.
This will allow non-Puppetized Splunk clients to connect to the various servicessince the default Splunk config isn't compatible with modern compability. Setting the deploymentserver to intermediate compatibility will allow these clients to make the initial connection, after which you can deploy a common_ssl_base config app to them with modern ssl compatibility.
The manifest below will also use the Splunk provided non-production certificates, instead of the ones signed by the Puppet CA.

![Example 2](example2.png)

```puppet
node 'splunk-server.internal.corp.tld' {
  class { 'splunk':
    httpport           => 8000,
    kvstoreport        => 8191,
    inputport          => 9997,
    sslcompatibility   => 'intermediate',
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
  }
}

node 'some-server.internal.corp.tld' {
  class { 'splunk':
    type => 'uf',
    ds   => 'splunk-server.internal.corp.tld:8089',
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
  }
}
```

### Example 3: 

One deployment/license server, one search head, and two indexers.
Note that for the search head to add the indexer as its search peer, the
indexer needs to be running **before** the search head manifest is executed.
This means that you'll have to manage intra-node dependencies manually or
through an orchestration tool like Terraform.

![Example 3](example3.png)

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
    service      => {
      ensure     => running,
      enable     => true,
    },
  }
}

node 'splunk-sh.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      # A plaintext password needed to be able to add search peers,
      # so also make sure the indexer you're pointing to is running,
      # you can remove this if everything is up and running:
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
    # splunk must be running to be able add search peers, 
    # you can remove this if everything is up and running:
    service      => {
      ensure     => running,
      enable     => true,
    },
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
    # splunk must be running for it to be added as search peer,
    # you can remove this if everything is up and running
    service      => {
      ensure     => running,
      enable     => true,
    }
  }
}
```

### Example 4: 

A Splunk indexer cluster consisting of one deployment/license/searchhead server, a cluster master, and three cluster peers.
The cluster master also acts as license master.

![Example 4](example4.png)

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
    lm           => 'splunk-cm.internal.corp.tld:8089',
    tcpout       => [ 'splunk-idx1.internal.corp.tld:9997', 'splunk-idx2.internal.corp.tld:9997', ],
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
    tcpout       => [ 'splunk-idx1.internal.corp.tld:9997', 'splunk-idx2.internal.corp.tld:9997', ],
    clustering   => {
      mode               => 'master',
      replication_factor => 2,
      search_factor      => 2,
    }
  }
}

node 'splunk-idx1.internal.corp.tld', 
     'splunk-idx2.internal.corp.tld',
     'splunk-idx3.internal.corp.tld' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-cm.internal.corp.tld:8089',
    clustering   => {
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.tld:8089',
    }
  }
}
```

### Example 5

Enabling Single Sign-On through Active Directory Federation Services (ADFS) as an Identity provider:

```
node 'splunk-sh.internal.corp.tld' {
  class { 'splunk':
    ...
    auth           => { 
      authtype     => 'SAML',
      saml_idptype => 'ADFS',
      saml_idpurl  => 'https://sso.internal.corp.tld/adfs/ls',
    },
    ...
  }
}
```

On the ADFS side:

1. Add a new Relying Party Trust, by importing the XML from `https://splunk-sh.internal.corp.tld/saml/spmetadata`. Since this metadata is kept behind a Splunk login, you'll have to:

    - first browse to `https://splunk-sh.internal.corp.tld/account/login?loginType=Splunk`
    - then browse to `https://splunk-sh.internal.corp.tld/saml/spmetadata`, and copy/paste the SAML metadata XML to the Windows server. 
    - import the SAML metadata XML from the relying party (Splunk) from a file

1. Add a new claim rule to map Active Directory attributes to new claims
   
   ![ADFS get attributes claim rule for Splunk](adfs_claim_rules_get_attrs.png)

1. import the Splunk Root CA (/opt/splunk/etc/auth/cacert.pem) in the Trusted Root Certificates store of the Windows server,
1. If you're using your own certificates: `Set-ADFSRelyingPartyTrust -TargetIdentifier splunk-sh1.internal.corp.tld -EncryptionCertificateRevocationCheck none`
1. If you're using your own certificates: `Set-ADFSRelyingPartyTrust -TargetIdentifier splunk-sh1.internal.corp.tld -SigningCertificateRevocationCheck none`
1. `Set-ADFSRelyingPartyTrust -TargetIdentifier splunk-sh1.internal.corp.tld -EncryptClaims $False`
1. `Set-ADFSRelyingPartyTrust -TargetIdentifier splunk-sh1.internal.corp.tld -SignedSamlRequestsRequired $False`, otherwise you'll find messages like these in the Windows Eventlog: `System.NotSupportedException: ID6027: Enveloped Signature Transform cannot be the last transform in the chain.`

You can use the SAML tracer Firefox plugin to see what gets posted to Splunk via ADFS after a succesful authentication. The relevant part should look something like this:

```
        ...
        <Subject>
            <NameID>jfolmer@testlab.local</NameID>
            <SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
                <SubjectConfirmationData InResponseTo="host15.testlab.local.12.AF9F4C1A-EAEA-4EF5-A501-E57AB33D7776"
                                         NotOnOrAfter="2016-11-04T21:23:34.597Z"
                                         Recipient="https://host15.testlab.local:8000/saml/acs"
                                         />
            </SubjectConfirmation>
        </Subject>
        <Conditions NotBefore="2016-11-04T21:18:34.581Z"
                    NotOnOrAfter="2016-11-04T22:18:34.581Z"
                    >
            <AudienceRestriction>
                <Audience>host15.testlab.local</Audience>
            </AudienceRestriction>
        </Conditions>
        <AttributeStatement>
            <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name">
                <AttributeValue>Jorrit Folmer</AttributeValue>
            </Attribute>
            <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress">
                <AttributeValue>jfolmer@testlab.local</AttributeValue>
            </Attribute>
            <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/role">
                <AttributeValue>Domain Users</AttributeValue>
                <AttributeValue>Splunk Admins</AttributeValue>
            </Attribute>
        </AttributeStatement>
        ...
```


### Example 6

Use LDAP as an authentication provider, e.g. with Active Directory. The example below also maps 2 groups in AD to Splunk admin, and 1 group to Splunk user.

```
node 'splunk-sh.internal.corp.tld' {
  class { 'splunk':
    ...
    auth           => { 
      authtype     => 'LDAP',
      ldap_host                 => 'dc01.internal.corp.tld',
      ldap_binddn               => 'CN=Splunk Service Account,CN=Users,DC=corp,DC=tld',
      ldap_binddnpassword       => 'changeme',
      ldap_sslenabled           => 0,
      ldap_userbasedn           => 'CN=Users,DC=corp,DC=tld',
      ldap_groupbasedn          => 'CN=Users,DC=corp,DC=tld;OU=Groups,DC=corp,DC=tld',
    },
    rolemap     => {
      'admin'   => 'Splunk Admins;Domain Admins',
      'user'    => 'Splunk Users',
    },
    ...
  }
}
```

### Example 7

Splunk search head clustering (SHC) not only requires configuration
management, but also some orchestration to get it up and running.

Since the SH Deployer also has an active role in configuration management, you
will have to take some extra steps in the right order to prevent Puppet and SH
deployer from interferring with each other.

```
node 'splunk-sh1.internal.corp.tld',
     'splunk-sh2.internal.corp.tld', 
     'splunk-sh3.internal.corp.tld'  {
  class { 'splunk':
    ...
    shclustering   => {
      mode         => 'searchhead',
      shd          => 'splunk-shd.internal.corp.tld:8089',
      pass4symmkey => 'SHCl33tsecret',
      label        => 'My First SHC',
    },
     ...
  }
}

node 'splunk-shd.internal.corp.tld' {
  class { 'splunk':
    ...
    shclustering   => {
      mode         => 'deployer',
      pass4symmkey => 'SHCl33tsecret',
    },
     ...
  }
}
```

Steps:

1. Do a puppet run on the SH deployer and SH cluster nodes, but don't start Splunk yet.
2. Copy the $SPLUNK_HOME/etc/apps/puppet_* directories created by Puppet from a SH cluster node to etc/shcluster/apps/ on the SH deployer
3. Start the SH deployer and the SH cluster nodes
4. Perform a `splunk bootstrap shcluster-captain -servers_list "https://splunk-sh1.internal.corp.tld:8089,https://splunk-sh2.internal.corp.tld:8089,https://splunk-sh1.internal.corp.tld:8089" -auth admin:changemeagain

### Example 8

Configure a multisite cluster with 2 sites with 1 indexer each.
Site 1 hosts splunk-cm and splunk-idx1. Site 2 hosts splunk-idx2.

```
node 'splunk-cm.internal.corp.tld', 
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Master Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    tcpout       => [ 'splunk-idx1.internal.corp.tld:9997', 'splunk-idx2.internal.corp.tld:9997', ],
    clustering   => {
      mode               => 'master',
      replication_factor => 2,
      search_factor      => 2,
      site               => 'site1',
      available_sites    => 'site1,site2',
      site_replication_factor => 'origin:1, total:2',
      site_search_factor => 'origin:1, total:2',
    }
  }
}

node 'splunk-idx1.internal.corp.tld', 
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-cm.internal.corp.tld:8089',
    clustering   => {
      site       => 'site1',
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.tld:8089',
    }
  }
}

node 'splunk-idx2.internal.corp.tld', 
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-cm.internal.corp.tld:8089',
    clustering   => {
      site       => 'site2',
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.tld:8089',
    }
  }
}

```


## Parameters

### Main splunk class

#### `type`

  Optional. When omitted it installs the Splunk server type.
  Use `type => "uf"` if you want to have a Splunk Universal Forwarder.

#### `httpport`

  Optional. When omitted, it will not start Splunk web.
  Set `httpport => 8000` if you do want to have Splunk web available.

#### `kvstoreport`

  Optional. When omitted, it will not start Mongodb.
  Set `kvstoreport => 8191` if you do want to have KVstore available.

#### `inputport`

  Optional. When omitted, it will not start an Splunk2Splunk listener.
  Set `kvstoreport => 9997` if you do want to use this instance as an indexer.

#### `tcpout`

  Optional. When omitted, it will not forward events to a Splunk indexer.
  Set `tcpout => 'splunk-idx1.internal.corp.tld:9997'` if you do want to
  forward events to a Splunk indexer. 

#### `package_source`

  Optional and for Windows only. Use this to point to the .msi installation file.
  This can be a UNC path like \\DC01\Company\splunkforwarder-6.6.1-aeae3fe0c5af-x64-release.msi

#### `splunk_os_user`

  Optional. Run the Splunk instance as this user. Defaults to `splunk`

#### `splunk_bindip`

  Optional. Bind to this specific IP instead of 0.0.0.0

#### `splunk_home`

  Optional. Used if you're running Splunk outside of /opt/splunk or
  /opt/splunkforwarder.

#### `lm`

  Optional. Used to point to a Splunk license manager.

#### `ds`

  Optional. Used to point to a Splunk deployment server

#### `ds_intermediate`

  Optional. Used to configure the deployment server as a deploymentclient.
  This is useful if you want to retain one central deployment server instead of
  multiple, for example one for each DMZ.  Defaults to undef.

#### `repositorylocation`

  Optional. Used to configure the location on the deployment client where the
  incoming apps from the deployment server are stored. Use `master-apps` or
  `shcluster/apps` if you want to use the deployment server to also deploy to
  intermediate locations on the cluster master or search head deployer.

#### `phonehomeintervalinsec`

  Optional. Unsed to configure the phonehomeinterval of the deploymentclient.
  Defaults to undef.

#### `sslcompatibility`

  Optional. Used to configure the SSL compatibility level as defined by
  Mozilla Labs:  

  - `modern` (default)
  - `intermediate`
  - `old`

#### `reuse_puppet_certs`

   Optional. By default the certificates signed by the Puppet CA will be reused. However if you want to do some quick testing with non-Puppetized nodes, set this to `false`, and make sure to point `sslcertpath => 'server.pem'` and `sslrootcapath => 'cacert.pem'` to the default Splunk testing certs.

   - `true` (default)
   - `false`

#### `sslcertpath`

   Optional. Can be together with `reuse_puppet_certs => false` to point to either your own certificates, or to the default Splunk provided testing certficates.

   Note that the path is relative to $SPLUNK_HOME/etc/auth/

#### `sslrootcapath`

   Optional. Can be together with `reuse_puppet_certs => false` to point to either your own CA certificates, or to the default Splunk provided testing CA certficates. 

   Note that the path is relative to $SPLUNK_HOME/etc/auth/

#### `admin`

  Optional. Used to create a local admin user with predefined hash, full
  name and email This is a hash with 3 members:

  - `hash` (SHA512 hash of the admin password. To generate the hash use one of:

     -  `grub-crypt --sha-512` (RHEL/CENTOS)
     -  `mkpasswd -m sha-512`  (Debian)
     -  `python -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))'`

  - `pass` (Plaintext password, only used for search heads to add search peers in distributed search)
  - `fn`   (Full name)
  - `email` (Email address)

#### `minfreespace`

  Optional. Used to specify the minimum amount of freespace in kb before Splunk stops indexing data.

#### `service`

  Optional. Used to manage the running and startup state of the
  Splunk/Splunkforwarder service. This is a hash with 2 members: 

  - `ensure` (not enabled by default)
  - `enable` (defaults to true)

#### `searchpeers`

  Optional. Used to point a Splunk search head to (a) Splunk indexer(s)

#### `clustering`

  Optional. Used to configure Splunk indexer clustering. This is a hash with 4 members:

  - `mode` (can be one of `master`,`searchhead`,`slave`)
  - `replication_factor`
  - `search_factor`
  - `cm` (points to cluster master in case of searchhead or slave)

  For multisite indexer clustering:

  - `thissite` (assigns this node to a site, value can be site1..site63. `site` is a reserved word in Puppet 4.x hence the choice for `thissite`)

  For cluster masters of multisite indexer clusters:

  - `available_sites` (e.g. 'site1,site2')
  - `site_replication_factor` (e.g. 'origin:1, total:2')
  - `site_search_factor` (e.g. 'origin:1, total:2')


#### `shclustering`

  Optional. Used to configure Splunk search head clustering. This is a hash with 3 members:

  - `mode` (can be one of `searchhead`,`deployer`)
  - `replication_factor`
  - `shd` (points to search head deployer, but see caveat in Example 7)

#### `use_ack`

  Optional. Used to request indexer acknowlegement when sending data.
  Defaults to false.

#### `version`

  Optional. Specify the Splunk version to use.
  For example to install the 6.2.2 version: `verion => '6.2.2-255606'`.

#### `auth`

  Optional. Used to configure Splunk authentication. 
  Currently supports 'Splunk' (default) 'SAML' and 'LDAP'.
  This is a hash with the following members:

  - `authtype` (can be one of `Splunk`,`LDAP`,`SAML`)
  - `saml_idptype` (specifies the SAML identity provider type to use, currently only supports `ADFS`)
  - `saml_idpurl` (specifies the base url for the identity provider, for ADFS IdP's this will be something like https://sso.corp.tld/adfs/ls )
  - `ldap_host`
  - `ldap_binddn`
  - `ldap_binddnpassword`
  - `ldap_userbasedn`
  - `ldap_groupbasedn`
  - `ldap_sslenabled`
  - `ldap_usernameattribute`
  - `ldap_groupmemberattribute`
  - `ldap_groupnameattribute`
  - `ldap_realnameattribute`

#### `requireClientCert`

  Optional. Used on a server to require clients to present an SSL certificate.
  Can be an array with:

  - `inputs`: require clients to present a certificate when sending data to Splunk
  - `splunkd`: require deployment clients and search peers to present a certificate when 


  For example require both splunkd and inputs connections to present a certificate:

  ```
  requireclientcert => ['splunkd','inputs'],
  ```

  Or only require forwarders to present a certificate when sending data;

  ```
  requireclientcert => 'inputs',
  ```


#### `rolemap`

  Optional. Specifies the role mapping for SAML and LDAP
  Defaults to:

  ```
  { 
    'admin' => 'Domain Admins', 
    'power' => 'Power Users', 
    'user'  => 'Domain Users',
  }
  ```

## Compatibility

Requires Splunk and Splunkforwarders >= 6.2.0.
However, if you still have versions < 6.2 , pass `sslcompatibility => 'intermediate'`.

If you have version >= 6.2.0 servers but with stock settings from a previous Splunk installation, also pass `sslcompatibility => 'intermediate'` in the universal forwarder declaration, otherwise the SSL connections to the deploymentserver will fail.

## Changelog

Moved to CHANGELOG.md

## Test coverage

Moved to TEST_COVERAGE.md

## Roadmap

- Managed service account for Windows installations
- Convert examples to patterns or building blocks

## Out-of-scope

- Search head load-balancing
- Search head pooling
- Managing apps or inputs on Splunkforwarders, see principle 1.
 
