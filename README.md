# Splunk deployments with Puppet

[![Travis CI build status](https://travis-ci.org/jorritfolmer/puppet-splunk.svg?branch=master)](https://travis-ci.org/jorritfolmer/puppet-splunk)

This Puppet module deploys Splunk instances on Windows and Linux in simple, distributed or (multisite) clustered topologies. It is used in production by organisations large and small, but can also be used to quickly validate solution architectures. For example on a 2016 MacBook Pro, setting up a multisite indexer cluster, a cluster master, a search head cluster, a search head deployer, LDAP authentication, etc, takes less than an hour.

Splunk demoed this module at the [Splunk .conf2017 breakout session](https://conf.splunk.com/sessions/2017-sessions.html#types=Breakout%20Session&loadall=204) "Automate All the Things! Moving Faster With Puppet and Splunk" beginning at the 29:42 mark.

Project homepage is at [https://github.com/jorritfolmer/puppet-splunk](https://github.com/jorritfolmer/puppet-splunk)

## Prerequisites

1. A Puppet master
2. A repository with splunk and splunkforwarder packages. See "Setting up a Splunk repository" if you need help setting it up for Red Hat, Debian or Windows environments

## Installation

1. SSH to your Puppet master
2. `puppet module install jorritfolmer-splunk`
3. Create your Splunk topology, see below for examples.

## Quick-start

Define a single standalone Splunk instance on Linux that you can use to index and search, for example with the trial license:

![Standalone Splunk instance](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/example1.png)

```puppet
node 'splunk-server.internal.corp.example' {
  class { 'splunk':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
}
```

(The equivalent in Hiera YAML format:)

```yaml
---
classes:
  - splunk

splunk::httpport:         8000
splunk::kvstoreport:      8191
splunk::inputport:        9997
```

Or define a single standalone Splunk instance on Windows with:

```puppet
node 'splunk-server.internal.corp.example' {
  class { 'splunk':
    package_source => '//dc01/Company/splunk-6.6.1-aeae3fe0c5af-x64-release.msi',
    httpport       => 8000,
    kvstoreport    => 8191,
    inputport      => 9997,
  }
}
```

(The equivalent in Hiera YAML format:)

```yaml
---
classes:
  - splunk

splunk::httpport:         8000
splunk::kvstoreport:      8191
splunk::inputport:        9997
splunk::package_source:   //dc01/Company/splunk-6.6.1-aeae3fe0c5af-x64-release.msi
```

See the other examples below for more elaborate topologies.

## Usage

By default, this module uses the Puppet client SSL key (4096 bits) and client certificates. By reusing the existing Puppet Certificate Authority, we don't have to set up a parallel CA. 

For quick testing in heterogeneous non-production environments you can revert to using the Splunk provides certs and CA with `reuse_puppet_certs => false`. Or you can point to your own key and certificates with `sslcertpath` and `sslrootcapath` if you are planning a zero-trust architecture.

The Splunk module doesn't manage the state of the splunk service, except to configure Splunk or Splunkforwarder at boot time. Have a look at the `service` parameter if you want to do more or less management of the Splunk service by this module.

### Example 1: 

Define a single standalone Splunk instance that you can use to index and search, for example with the trial license.
This time use the Splunk provided non-production testing certificates instead of reusing the ones signed by the Puppet CA, for example for testing in heterogeneous environments with non-Puppetized Splunk forwarders.

![Splunk instance standalone](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/example1.png)

```puppet
node 'splunk-server.internal.corp.example' {
  class { 'splunk':
    httpport           => 8000,
    kvstoreport        => 8191,
    inputport          => 9997,
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
    sslpassword        => 'password',
  }
}
```

To define a standalone Splunk instance running on Windows:

```puppet
node 'splunk-server.internal.corp.example' {
  class { 'splunk':
    package_source     => '//dc01/Company/splunk-6.6.1-aeae3fe0c5af-x64-release.msi',
    httpport           => 8000,
    kvstoreport        => 8191,
    inputport          => 9997,
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
    sslpassword        => 'password',
  }
}
```

### Example 2a: 

Extends the example above with a node that will run the Splunk universal forwarder. It uses the first server as Deployment Server (`ds =>`) where apps, inputs and outputs can be managed and deployed through Forwarder Management.

![Splunk instance with forwarder](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/example2.png)

```puppet
node 'splunk-server.internal.corp.example' {
  class { 'splunk':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
}

node 'some-server.internal.corp.example' {
  class { 'splunk':
    type => 'uf',
    ds   => 'splunk-server.internal.corp.example:8089',
  }
}
```

The equivalent for Windows environments:

```puppet
node 'splunk-server.internal.corp.example' {
  class { 'splunk':
    package_source => '//dc01/Company/splunk-6.6.1-aeae3fe0c5af-x64-release.msi',
    httpport       => 8000,
    kvstoreport    => 8191,
    inputport      => 9997,
  }
}

node 'some-server.internal.corp.example' {
  class { 'splunk':
    package_source => '//dc01/Company/splunkforwarder-6.6.1-aeae3fe0c5af-x64-release.msi',
    type           => 'uf',
    ds             => 'splunk-server.internal.corp.example:8089',
  }
}
```

### Example 2b: 

Almost identical to example 2a, except with some SSL downgrading, not suitable for production.
This will allow non-Puppetized Splunk clients to connect to the various services since the default Splunk config isn't compatible with SSL modern compability. Setting the deployment server to intermediate compatibility will allow these clients to make the initial connection, after which you can deploy a common_ssl_base config app to them with modern ssl compatibility.
The manifest below will also use the Splunk provided non-production certificates, instead of the ones signed by the Puppet CA.

![Splunk instance with forwarder in hybrid environments](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/example2.png)

```puppet
node 'splunk-server.internal.corp.example' {
  class { 'splunk':
    httpport           => 8000,
    kvstoreport        => 8191,
    inputport          => 9997,
    sslcompatibility   => 'intermediate',
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
    sslpassword        => 'password',
  }
}

node 'some-server.internal.corp.example' {
  class { 'splunk':
    type => 'uf',
    ds   => 'splunk-server.internal.corp.example:8089',
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
    sslpassword        => 'password',
  }
}
```

### Example 3: 

This example deploys one deployment/license server, one search head, and two indexers.
Note that for the search head to add the indexer as its search peer, the
indexer needs to be running **before** the search head manifest is executed.
This means that you'll have to manage intra-node dependencies manually or
through an orchestration tool like Terraform or Ansible.

![Splunk topology with indexer, search head and deployment server](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/example3.png)

```puppet
node 'splunk-ds.internal.corp.example' {
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
      'splunk-idx1.internal.corp.example:9997', 
      'splunk-idx2.internal.corp.example:9997',
    ],
    service      => {
      ensure     => running,
      enable     => true,
    },
  }
}

node 'splunk-sh.internal.corp.example' {
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
    lm           => 'splunk-ds.internal.corp.example:8089',
    ds           => 'splunk-ds.internal.corp.example:8089',
    tcpout       => [ 
      'splunk-idx1.internal.corp.example:9997', 
      'splunk-idx2.internal.corp.example:9997', ],
    # Use these search peers
    searchpeers  => [ 
      'splunk-idx1.internal.corp.example:8089', 
      'splunk-idx2.internal.corp.example:8089', ],
    # splunk must be running to be able add search peers, 
    # you can remove this if everything is up and running:
    service      => {
      ensure     => running,
      enable     => true,
    },
  }
}

node 'splunk-idx1.internal.corp.example', 'splunk-idx2.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Indexer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-ds.internal.corp.example:8089',
    ds           => 'splunk-ds.internal.corp.example:8089',
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

![Splunk indexer cluster](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/example4.png)

```puppet
node 'splunk-sh.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Search Head Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    kvstoreport  => 8191,
    lm           => 'splunk-cm.internal.corp.example:8089',
    tcpout       => [ 'splunk-idx1.internal.corp.example:9997', 'splunk-idx2.internal.corp.example:9997', ],
    clustering   => {
      mode       => 'searchhead',
      cm         => 'splunk-cm.internal.corp.example:8089',
    }
  }
}

node 'splunk-cm.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Master Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    tcpout       => [ 'splunk-idx1.internal.corp.example:9997', 'splunk-idx2.internal.corp.example:9997', ],
    clustering   => {
      mode               => 'master',
      replication_factor => 2,
      search_factor      => 2,
    }
  }
}

node 'splunk-idx1.internal.corp.example', 
     'splunk-idx2.internal.corp.example',
     'splunk-idx3.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-cm.internal.corp.example:8089',
    clustering   => {
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.example:8089',
    }
  }
}
```

### Example 5

This snippet enables Single Sign-On on the Search Head through Active Directory Federation Services (ADFS) as an Identity provider. See the chapter "Splunk with ADFS" for more details and troubleshooting.

```
node 'splunk-sh.internal.corp.example' {
  class { 'splunk':
    ...
    auth           => { 
      authtype     => 'SAML',
      saml_idptype => 'ADFS',
      saml_idpurl  => 'https://sso.internal.corp.example/adfs/ls',
    },
    ...
  }
}
```

To enable ADFS SAML authentication in a Search Head Cluster, add fqdn and entityid parameters:

```
node 'splunk-sh01.internal.corp.example' {
  class { 'splunk':
    ...
    auth            => { 
      authtype      => 'SAML',
      saml_idptype  => 'ADFS',
      saml_idpurl   => 'https://sso.internal.corp.example/adfs/ls',
      saml_fqdn     => 'https://splunk.internal.corp.example:8000',
      sqml_entityid => 'splunk.internal.corp.example',
    },
    ...
  }
}
```

### Example 6

This snippet enables LDAP authentication on a Search Head, e.g. with Active Directory. The example below also maps 2 groups in AD to Splunk admin, and 1 group to Splunk user.

```
node 'splunk-sh.internal.corp.example' {
  class { 'splunk':
    ...
    auth           => { 
      authtype     => 'LDAP',
      ldap_host                 => 'dc01.internal.corp.example',
      ldap_binddn               => 'CN=Splunk Service Account,CN=Users,DC=corp,DC=example',
      ldap_binddnpassword       => 'changeme',
      ldap_sslenabled           => 0,
      ldap_userbasedn           => 'CN=Users,DC=corp,DC=example',
      ldap_groupbasedn          => 'CN=Users,DC=corp,DC=example;OU=Groups,DC=corp,DC=example',
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
node 'splunk-sh1.internal.corp.example',
     'splunk-sh2.internal.corp.example', 
     'splunk-sh3.internal.corp.example'  {
  class { 'splunk':
    ...
    shclustering   => {
      mode         => 'searchhead',
      shd          => 'splunk-shd.internal.corp.example:8089',
      pass4symmkey => 'SHCl33tsecret',
      label        => 'My First SHC',
    },
     ...
  }
}

node 'splunk-shd.internal.corp.example' {
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
2. Copy the $SPLUNK_HOME/etc/apps/puppet_* directories created by Puppet from one of the Search Head Cluster nodes to etc/shcluster/apps/ on the Search Head Deployer
3. Disable Puppet on the Search Head Cluster nodes to prevent Puppet from interfering with the configuration bundle pushes from the Search Head Deployer.
3. Start the SH deployer and the SH cluster nodes
4. Do an apply shcluster-bundle on the Search Head Deployer
4. Perform a `splunk bootstrap shcluster-captain -servers_list "https://splunk-sh1.internal.corp.example:8089,https://splunk-sh2.internal.corp.example:8089,https://splunk-sh1.internal.corp.example:8089" -auth admin:changemeagain

### Example 8

Configure a multisite cluster with 2 sites with 1 indexer each.
Site 1 hosts splunk-cm and splunk-idx1. Site 2 hosts splunk-idx2.

```
node 'splunk-cm.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Master Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    tcpout       => [ 'splunk-idx1.internal.corp.example:9997', 'splunk-idx2.internal.corp.example:9997', ],
    clustering   => {
      mode               => 'master',
      replication_factor => 2,
      search_factor      => 2,
      thissite           => 'site1',
      available_sites    => 'site1,site2',
      site_replication_factor => 'origin:1, total:2',
      site_search_factor => 'origin:1, total:2',
    }
  }
}

node 'splunk-idx1.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-cm.internal.corp.example:8089',
    clustering   => {
      thissite   => 'site1',
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.example:8089',
    }
  }
}

node 'splunk-idx2.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-cm.internal.corp.example:8089',
    clustering   => {
      thissite   => 'site2',
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.example:8089',
    }
  }
}

```

### Example 9

Configure an index cluster with indexer discovery 

```
node 'splunk-cm.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Master Administrator',
      email      => 'changemeagain@example.com',
    },
    httpport     => 8000,
    tcpout       => 'indexer_discovery',
    clustering   => {
      mode               => 'master',
      replication_factor => 2,
      search_factor      => 2,
      indexer_discovery  => true,
    }
  }
}

node 'splunk-idx1.internal.corp.example','splunk-idx2.internal.corp.example' {
  class { 'splunk':
    admin        => {
      hash       => '$6$MR9IJFF7RBnVA.k1$/30EBSzy0EJKZ94SjHFIUHjQjO3/P/4tx0JmWCp/En47MJceaXsevhBLE2w/ibjHlAUkD6k0U.PmY/noe9Jok0',
      fn         => 'Cluster Peer Administrator',
      email      => 'changemeagain@example.com',
    },
    inputport    => 9997,
    lm           => 'splunk-cm.internal.corp.example:8089',
    clustering   => {
      mode       => 'slave',
      cm         => 'splunk-cm.internal.corp.example:8089',
    }
  }
}

node 'some-server.internal.corp.example' {
  class { 'splunk':
    type       => 'uf',
    tcpout     => 'indexer_discovery',
    clustering => {
      cm       => 'splunk-cm.internal.corp.example:8089',
    }
  }
}

```

## Puppet Enterprise

If you're using the Puppet Enterprise web interface, type "splunk" at the Add
new class input and configure the parameters like httpport, inputport etc like
in the screenshot below:

![Using Puppet enterprise web interface to add Splunk class](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/puppet_enterprise_add_splunk_class.png)

Structured parameters like admin, clustering, auth need to be specified in valid JSON. See the "Tips for specifying parameter and variable values" over at Puppet Enterprise docs: https://puppet.com/docs/pe/2018.1/managing_nodes/grouping_and_classifying_nodes.html#set-node-group-variables.

One caveat: you cannot specify the admin hash in JSON due to the dollar signs in the SHA512 hash. Even though the PE docs mention you should escape $ to prevent variable interpolation, this doesn't seem to work for values in JSON.

| Status | Statement | Reason
|------|-----|-----
| **Works** | `{"pass": "changemeagain"}` | Valid JSON
| Doesn't work | `{'pass': 'changemeagain'}` | Invalid JSON
| Doesn't work | `{pass: "changemeagain"}` | Invalid JSON
| Doesn't work | `{pass= "changemeagain"}` | Invalid JSON
| Doesn't work | `{"hash": "$6$MR9IJetc"}` | Valid JSON but $ causes variable interpolation
| Doesn't work | `{"hash": "\$6\$MR9IJetc"}` | Valid JSON but escaped $ causes PE webgui to interfere

If for one reason or another the PE web gui says "Converted to string" while you're entering JSON, you should assume your structured parameter to not be interpreted incorrectly.

## Splunk with ADFS 

### Setup

1. Add a new Relying Party Trust in AD FS Management Console, by importing the XML from `https://splunk-sh.internal.corp.example/saml/spmetadata`. Since this metadata is kept behind a Splunk login, you'll have to:

    - first browse to `https://splunk-sh.internal.corp.example/account/login?loginType=Splunk`
    - then browse to `https://splunk-sh.internal.corp.example/saml/spmetadata`, and copy/paste the SAML metadata XML to the Windows server. 
    - import the SAML metadata XML from the relying party (Splunk) from a file

1. Add a new claim rule to map Active Directory attributes to new claims
   
   ![ADFS get attributes claim rule for Splunk](https://raw.githubusercontent.com/jorritfolmer/puppet-splunk/master/adfs_claim_rules_get_attrs.png)

1. Disable EncryptClaims on the ADFS side: Splunk only supports signed SAML responses: `Set-ADFSRelyingPartyTrust -TargetIdentifier splunk-sh1.internal.corp.example -EncryptClaims $False`
1. Disable SigningCertificateRevocationCheck on the ADFS side if you're using your own self signed certificates without CRL: `Set-ADFSRelyingPartyTrust -TargetIdentifier splunk-sh1.internal.corp.example -SigningCertificateRevocationCheck none`

You can use the SAML tracer Firefox plugin to see what gets posted to Splunk via ADFS after a succesful authentication. The relevant part should look something like this:

```
        ...
        <Subject>
            <NameID>jfolmer@testlab.example</NameID>
            <SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
                <SubjectConfirmationData InResponseTo="host15.testlab.example.12.AF9F4C1A-EAEA-4EF5-A501-E57AB33D7776"
                                         NotOnOrAfter="2016-11-04T21:23:34.597Z"
                                         Recipient="https://host15.testlab.example:8000/saml/acs"
                                         />
            </SubjectConfirmation>
        </Subject>
        <Conditions NotBefore="2016-11-04T21:18:34.581Z"
                    NotOnOrAfter="2016-11-04T22:18:34.581Z"
                    >
            <AudienceRestriction>
                <Audience>host15.testlab.example</Audience>
            </AudienceRestriction>
        </Conditions>
        <AttributeStatement>
            <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name">
                <AttributeValue>Jorrit Folmer</AttributeValue>
            </Attribute>
            <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress">
                <AttributeValue>jfolmer@testlab.example</AttributeValue>
            </Attribute>
            <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/role">
                <AttributeValue>Domain Users</AttributeValue>
                <AttributeValue>Splunk Admins</AttributeValue>
            </Attribute>
        </AttributeStatement>
        ...
```

### ADFS troubleshooting

Steps:

1. Get the ADFS relaying party trust settings from the ADFS server, e.g. through powershell: `Get-AdfsRelyingPartyTrust -Identifier host11.testlab.example`. Configuration settings to check:
    - SigningCertificateRevocationCheck: should be None for self-signed certs
    - EncryptClaims: should be $false because Splunk only supports signed claims
    - Identifier: should match the entityId in Splunk's authentication.conf
    - SignedSamlRequestsRequired: should be $true if you don't want your samlrequests to be man-in-the-middled
    - SignatureAlgorithm: should match the one in Splunk's authentication.conf, defaults to SHA-1, on ADFS defaults to SHA-256
2. Check the ADFS/Admin channel in the Windows Event Log for errors.

The Splunk provided SPMetadata.xml only covers some parameters for a Relaying Party Trust. This means there is a possibility for settings between Splunk and ADFS to diverge. For example regarding hashing with SHA-1 or SHA-256, CRL checking, Claim encryption etc.

Errors you may encounter with Splunk and ASFS 3.0 on Server 2012R2 or ADFS 4.0 on Server 2016:

| Splunk | ADFS | Error | Solution
|--------|------|-------|-----------
|  X     |      | IDP failed to authenticate request. Status Message="" Status Code="Responder" | Splunk received a "urn:oasis:names:tc:SAML:2.0:status:Responder" code in the SAML response. Check the AD FS/Admin event log channel on the AD FS server.
|  X     |      | The '/samlp:Response/saml:Assertion' field in the saml response from the IdP does not match the configuration. Ensure the configuration in Splunk matches the configuration in the IdP. | Disable EncryptClaims on the ADFS side. Splunk only supports signed SAML responses, non encrypted ones.
|       |   X   | SamlProtocolSignatureAlgorithmMismatchExeption: MSIS7093: The message is not signed with expected signature algorithm. Message is signed with signature algorithm http://www.w3.org/2000/09/xmldsig#rsa sha1. Expected signature algorithm http://www.w3.org/2001/04/xmldsig-more#rsa-sha256. | AD FS expects a SHA256 hash in the SAML request, but probably gets a SHA1 which is the Splunk default. Change the hash to SHA1 in the AD FS Relaying Trust properties -> Advanced. Or upgrade the `signatureAlgorithm` in Splunk's authentication.conf
|        |  X   | "An error occurred"  with RequestFailedException: MSIS7065: There are no registered protocol handlers on path /adfs/ls to process the incoming request. | Don't use a private browser window
|        |  X   |  "An error occurred" with AD FS / Admin / Event ID 364: Exception details: System.UriFormatException: Invalid URI: The format of the URI could not be determined. | There is a mismatch between the entityId as declared in Splunks authentication.conf and AD FS Relaying Party Identifier. They should be the same.
|        |  X   | Exception details: System.ArgumentOutOfRangeException: Not a valid Win32 FileTime. Parameter name: fileTime | Although the error message suggests time issues, this appears to happen only in some environments when a user logs in with the canonical domain name e.g. ad\user, instead of user@ad.corp.example or ad.corp.example\user. Authentication succeeds in all 3 cases, but only 2 without error.
|        |  X   | SamlProtocolSignatureVerificationException: MSIS7085: The server requires a signed SAML authentication request but no signature is present. | Splunk doesn't sign SAML requests but the IdP requires it.
|        |  X   | On logout "An error occurred" with AD FS / Admin / Event ID 364:System.ArgumentNullException: Value cannot be null. Parameter name: collection | This happens on ADFS 4.0 servers and is supposed to be fixed with a june 2017 Microsoft KB
|        |  X   | RevocationValidationException: MSIS3015: The signing certificate of the claims provider trust 'somehost' identified by thumbprint '33BC4ABFF11151559240DE9CA2C95C632C3E321B' is not valid | If you're using self-signed certificates disable signing certificate revocation checking
|        |  X   | System.NotSupportedException: ID6027: Enveloped Signature Transform cannot be the last transform in the chain. | Set Splunk to NOT sign outgoing SAML requests, and require ADFS to not require signed requests. This happened on older Splunk versions that sent malformed signatures.
|   X    |      | Verification of SAML assertion using the IDP's certificate provided failed. Unknown signer of SAML response | Splunk doesn't use the right certificate to validate SAML responses. Splunk should have the ADFS "Token signing certificate" to verify assertions. Specify this certificate in authentication.conf under `idpCertPath`
|   X    |      | The 'NotBefore' condition could not be verified successfully. The saml response is not valid. | Splunk received a SAML response with a NotBefore data in the future. Ensure NTP is deployed and working on all participating systems. If NTP is deployed but there is a small subsecond drift, you could also adjust the NotBeforeSkew setting with Powershell on the ADFS side to 1 minute. Even if `ntpq -pn` show a positive drift of only 100 ms, this will become an issue because the SAML response includes a NotBefore with millisecond resolution.

## Setting up a Splunk repository

### Red Hat/CentOS (YUM)

If you don't already have a local repository server, the quickest way is to install Apache on the Puppet master and have this serve the yum repository.

1. `yum install httpd`
2. `yum install createrepo`
3. `mkdir /var/www/html/splunk`
4. `cd /var/www/html/splunk`
5. download splunk-x.y.x.rpm
6. download splunk-forwarder-x.y.x.rpm
7. `createrepo .`
8. make sure Apache allows directory index listing
9. surf to http://your.repo.server.example/splunk and check if you get a directory listing

Then add something like this to every node definition in site.pp, and require it from the splunk class so it it evaluated before the splunk class.

```
yumrepo { "splunk":
  baseurl => "http://your.repo.server.example/splunk",
  descr => "Splunk repo",
  enabled => 1,
  gpgcheck => 0
}
```

### Debian/Ubuntu (APT)

If you don't already have a local repository server, the quickest way is to install Apache on the Puppet master and have this serve the APT repository.

1. `apt-get install apache2`
2. `apt-get install dpkg-dev`
3. `mkdir /var/www/html/splunk`
4. `cd /var/www/html/splunk`
5. download splunk-x.y.x.deb
6. download splunk-forwarder-x.y.x.deb
7. `dpkg-scanpackages . /dev/null |gzip -c > Packages.gz`
8. make sure Apache allows directory index listing
9. surf to http://your.rhel-repo.server.example/splunk and check if you get a directory listing

Then add something like this to every node definition in site.pp, and make sure to require these files from the splunk class so they are evaluated before the splunk class. Because the APT repository above isn't signed, puppet won't be able to install splunk or splunkforwarder, except when setting `APT::Get::AllowUnauthenticated` somewhere in `/etc/apt/apt.conf.d/`. You may have to run apt-get update before the Splunk repository is available in apt-get.

```
file { "/etc/apt/apt.conf.d/99allowunsigned":
  ensure => present,
  content => "APT::Get::AllowUnauthenticated "true";\n",
}
file { "/etc/apt/sources.list.d/splunk.list":
  ensure => present,
  content => "deb http://your.apt-repo.server.example/splunk ./\n",
}
```

### Windows CIFS share (MSI)

For Windows installations just put the .msi Splunk installation files for
Windows on a share that is accessible from all your Windows servers.

1. create a share that can be accessed by all your Windows servers
2. download the relevant Splunk .msi files from the Splunk website into this share
3. specify `package_source` and point to one of these .msi files


## Parameters

### `admin`

Optional. Used to create a local admin user with predefined hash, full
name and email This is a hash with 3 members:

- `hash` (SHA512 hash of the admin password. To generate the hash use one of:
     -  `grub-crypt --sha-512` (RHEL/CENTOS)
     -  `mkpasswd -m sha-512`  (Debian)
     -  `python -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))'`
- `pass` (Plaintext password, only used for search heads to add search peers in distributed search)
- `fn`   (Full name)
- `email` (Email address)

  
### `auth`

Optional. Used to configure Splunk authentication. 
Currently supports 'Splunk' (default), 'SAML' and 'LDAP'.
This is a hash with the following members:

- `authtype` (can be one of `Splunk`,`LDAP`,`SAML`)
- `saml_idptype` (specifies the SAML identity provider type to use, currently only supports `ADFS`)
- `saml_idpurl` (specifies the base url for the identity provider, for ADFS IdP's this will be something like https://sso.corp.example/adfs/ls )
- `saml_signauthnrequest` (sign outgoing SAML requests to ADFS: defaults to true)
- `saml_signedassertion` (expect assertions from ADFS to be signed: defaults to true)
- `saml_signaturealgorithm` (specifies the signature algorithm to hash requests to ADFS with, and support responses from ADFS.)
- `saml_entityid` (defaults to $fqdn, override in search head clustering setups to make every search head use the same Relaying Party Trust in ADFS)
- `saml_fqdn` (not present by default, override in search head clustering setups to have ADFS redirect to this URL which should normally be the URL handled by a load balancer. If you omit this, ADFS will redirect to the individual search head that make de SAML request which isn't what you want in SHC)
- `ldap_host`
- `ldap_port`: optional if you use a non-standard port
- `ldap_binddn`
- `ldap_binddnpassword`
- `ldap_userbasedn`
- `ldap_groupbasedn`
- `ldap_sslenabled`: default
- `ldap_usernameattribute`
- `ldap_groupmemberattribute`
- `ldap_groupnameattribute`
- `ldap_realnameattribute`
- `ldap_nestedgroups`: optional, set to 1 if you want Splunk to expand nested groups

### `clustering`

Optional. Used to configure Splunk indexer clustering. This is a hash with 6 members:

- `mode` (can be one of `master`,`searchhead`,`slave`, or `forwarder`)
- `replication_factor`
- `search_factor`
- `cm` (points to cluster master in case of searchhead,slave, or forwarder in case of indexer discovery)
- `indexer_discovery` (enables indexer discovery on the master node)
- `forwarder_site_failover` (Configures sites that fowarders are allowed to fail over to. `site1:site` allows fowarders in site1 to fail over to indexers in site2 if the local indexers are unavailable.)

For multisite indexer clustering:

- `thissite` (assigns this node to a site, value can be site1..site63. `site` is a reserved word in Puppet 4.x hence the choice for `thissite`)

For cluster masters of multisite indexer clusters:

- `available_sites` (e.g. 'site1,site2')
- `site_replication_factor` (e.g. 'origin:1, total:2')
- `site_search_factor` (e.g. 'origin:1, total:2')

### `ds`

Optional. Used to point to a Splunk deployment server

### `ds_intermediate`

Optional. Used to configure the deployment server as a deploymentclient.
This is useful if you want to retain one central deployment server instead of
multiple, for example one for each DMZ.  Defaults to undef.

### `httpport`

Optional. When omitted, it will not start Splunk web.
Set `httpport => 8000` if you do want to have Splunk web available.

### `inputport`

Optional. When omitted, it will not start an Splunk2Splunk listener.
Set `kvstoreport => 9997` if you do want to use this instance as an indexer.

### `kvstoreport`

Optional. When omitted, it will not start Mongodb.
Set `kvstoreport => 8191` if you do want to have KVstore available.

### `lm`

Optional. Used to point to a Splunk license manager.
  
### `maxbackupindex`

Optional. Specifies the number of rotated log files in `$SPLUNK_HOME/var/log/splunk` to keep around.
Defaults to 1.
  
### `maxfilesize`

Optional. Specifies the max file size of log files in `$SPLUNK_HOME/var/log/splunk`.
Defaults to 10MB.
  
### `maxKBps`

Optional. Specifies the max throughput rate for outgoing data.

### `mgmthostport`

Optional. When omitted, Splunk defaults apply and Splunk will use the default 8089 port.
Set `mgmthostport => '127.0.0.1:9991' if you want to move the 8089 port to 9991` 
Set `mgmthostport => 'disable' if you want to disable the Splunk management port, for example on Universal Forwarders
  
### `minfreespace`

Optional. Used to specify the minimum amount of freespace in kb before Splunk stops indexing data.

### `package_source`

Optional.

* For Windows: Use this to point to the .msi installation file. This can be a UNC path like \\DC01\Company\splunkforwarder-6.6.1-aeae3fe0c5af-x64-release.msi
* For Linux: Use this to point to the URL of a Splunk RPM file. WARNING: this will cause the entire RPM file to be downloaded at *every* Puppet run by the package provider, even though it is already installed. Create your own local repository if you don't want this.

### `phonehomeintervalinsec`

Optional. Used to configure the phonehomeinterval of the deploymentclient.
Defaults to undef.

### `pool_suggestion`

Optional. Used to perform license pool management at the indexers instead of at the licence master.
  
### `repositorylocation`

Optional. Used to configure the location on the deployment client where the incoming apps from the deployment server are stored. Use `master-apps` or `shcluster/apps` if you want to use the deployment server to also deploy to intermediate locations on the cluster master or search head deployer.
  
### `reuse_puppet_certs`

Optional. By default the certificates signed by the Puppet CA will be reused. However if you want to do some quick testing with non-Puppetized nodes, set this to `false`, and make sure to point `sslcertpath => 'server.pem'` and `sslrootcapath => 'cacert.pem'` to the default Splunk testing certs.

- `true` (default)
- `false`

### `reuse_puppet_certs_for_web`

Optional. By default the certificates signed by the SplunkCommonCA will be used to secure the Splunkweb interface at 8000/tcp
If you want to use the one signed by the Puppet CA, set this option to true.

- `false` (default)
- `true`

### `requireclientcert`

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

### `rolemap`

Optional. Specifies the role mapping for SAML and LDAP
Defaults to:

```
{ 
  'admin' => 'Domain Admins', 
  'power' => 'Power Users', 
  'user'  => 'Domain Users',
}
```

### `service`

Optional. Used to manage the running and startup state of the Splunk/Splunkforwarder service. This is a hash with 3 members: 

- `ensure` (not enabled by default)
- `enable` (defaults to true)
- `managed` (default to undef): set this to `false` if you don't want the module to anything with the Splunk service at all. For example if you want to use systemd unit files instead of the SysV scripts provided by Splunk.

### `searchpeers`

Optional. Used to add a search peer to the current Splunk instance.

This parameter requires the admin password to be present in plain text as the 'pass' member of the auth parameter.
Best practice is to remove this plaintext and searchpeer parameter after adding all the required search peers.

You can use this to: 
- add one or more indexers to a search head
- add a Splunk instance so the Monitoring Console can monitor it, for example if you're montoring a clustered Splunk deloyment from the cluster master. In this case the search head isn't automatically present in the MC overview, so you have to add the search head as a search peer.

After adding the search peeer, an empty `hostname:8090.done` file in created in`$SPLUNK_HOME/etc/auth/distServerKeys`, so the Puppet module knows not to run the add search peer command again and again. Remove this file if you want to re-add the same search peer.
  
### `secret`

Optional. Specifies the contents for the `$SPLUNK_HOME/etc/auth/splunk.secret` file. This can be helpful when distributing prehashed passwords across multiple Splunk instances.

Example:

```
secret => 'kGzHMGUe7GH0ZlOOIMVKkuEpDx1i1PKgq3E4p2ibmXuCKqJAKCENvY5a4QijxyrYt5Spt4T0.Qda5az6CDBvoTiYjMKsvz/p/ey/eLWOC6GQIEzARBUDasl84v9PIo6TA4AF4SxdygKGjbBekm9kV4UL2uMLnUGpQ5d.yIqBxqpHy8lgQhCTEIwQPxKRu9UMnBmEjnAmakn7Rmd3kMKq/.fnJdMgHhIZIK1ZcT6jm2vllL3sE42DBHy1DoRnYK'
```

### `shclustering`

Optional. Used to configure Splunk search head clustering. This is a hash with 3 members:

- `mode` (can be one of `searchhead`,`deployer`)
- `replication_factor`
- `shd` (points to search head deployer, but see caveat in Example 7)

### `sslcompatibility`

Optional. Used to configure the SSL compatibility level as defined by Mozilla Labs:  

- `modern` (default)
- `intermediate`
- `old`

Also see the Compatibility section below.

### `splunk_os_user`

Optional. Run the Splunk instance as this user. Defaults to `splunk`

### `splunk_bindip`

Optional. Bind to this specific IP instead of 0.0.0.0

### `splunk_db`

Optional. Used to set the location where Splunk stores its indexes. Unsupported on Windows instances.

For 3.x releases of Puppet-Splunk this will only change the SPLUNK_DB variable in etc/splunk-launch.conf if set. If unset, it will not remove the setting to prevent surprises when it has been previously set manually.

For 4.x future releases this may change.

### `sslcertpath`

Optional. Can be together with `reuse_puppet_certs => false` to point to either your own certificates, or to the default Splunk provided testing certficates.

Note that the path is relative to `$SPLUNK_HOME/etc/auth/`

### `sslrootcapath`

Optional. Can be together with `reuse_puppet_certs => false` to point to either your own CA certificates, or to the default Splunk provided testing CA certficates. 

Note that the path is relative to `$SPLUNK_HOME/etc/auth/`
   
### `sslpassword`

Optional. Specify the password for the RSA key. Can be plaintext or a Splunk hash. For a Splunk hash you should also specify the Splunk secret.

### `sslverifyservercert`

Optional. Used on a client to require servers to present an SSL certificate from the same CA as the client.
Can be an array with:

- `outputs`: require servers to present a certificate when sending data to Splunk
- `splunkd`: require deployment servers and search peers to present a certificate from the same CA


For example require both splunkd and outputs connections to present a certificate from the same CA:

```
sslverifyservercert => ['splunkd','outputs'],
```

Or only require Splunk indexers to present a certificate with the same CA when sending data;

```
sslverifyservercert => 'outputs',
```
  
### `type`

Optional. When omitted it installs the Splunk server type.
Use `type => "uf"` if you want to have a Splunk Universal Forwarder.
  
### `tcpout`

Optional. When omitted, it will not forward events to a Splunk indexer.

Set `tcpout => 'splunk-idx1.internal.corp.example:9997'` if you do want to forward events to a Splunk indexer. 

Set `tcpout => 'indexer_discovery' if you want to use indexer discovery instead of specifying indexers manually. Requires specifying a cluster master through:

```
  clustering => {
     cm      => 'splunk-cm.internal.corp.example:8089'
  }
```

### `use_ack`

Optional. Used to request indexer acknowlegement when sending data.
Defaults to false.

### `version`

Optional. Specify the Splunk version to use.
For example to install the 6.2.2 version: `verion => '6.2.2-255606'`.

## Compatibility

Set sslcompatibility in these cases:

* If you have older 6.0, 6.1, 6,2 or 6.3 releases that connect to Splunk 6.6 (see SPL-141961, SPL-141964)
* If you have older 6.0, 6,1 releases that connect to Splunk 6.2, 6,3, 6,4 or 6,5
* If you have 6.2, 6,3, 6.4 or 6.5 releases with default Splunk ssl settings that connect to Splunk managed by this module

## Principles

Development of this module is done with the following principles in mind:

1. **Technical Management** Puppet is used to configure the technical infrastructure of a Splunk deployment. It tries to keep away from Splunk functional administration as much as possible. For example, deploying Splunk apps to forwarders is best left to Splunk's multi-platform deployment server.
2. **Power to the Splunkers.** A Splunk installation used for security monitoring should typically not be administered by the same IT or IT-infra teams it's supposed to be monitoring. This Puppet module should smooth the path towards implementing segregation of duties between administrators and watch(wo)men (ISO 27002 12.4.3 or BIR 10.10.3).
3. **Supports any topology.** Single server? Redundant multisite clustering? Heavy forwarder in a DMZ?
4. **Secure by default**.
  - Splunk runs as user splunk instead of root.
  - No services are listening by default except the bare minimum (8089/tcp)
  - TLSv1.1 and TLSv1.2 are enabled by default
  - Perfect Forward Secrecy (PFS) using Elliptic curve Diffie-Hellman (ECDH)
  - Ciphers are set to [modern compatibility](https://wiki.mozilla.org/Security/Server_Side_TLS)
  - Admin password can be set using its SHA512 hash in the Puppet manifests instead of plain-text.

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
 
## Contributers

These people haves contributed pull requests, issues, ideas or otherwise spent time improving this module:

- Alexander M (Rathios)
- Chris Bowles (cbowlesUT)
- Dimitri Tischenko (timidri)
- dkangel37
- Dustin Wheeler (mdwheele)
- FlorinTar
- Jason Spencer (jespencer)
- Joachim la Poutré (sickbock)
- jsushetski
- Michael Fyffe (TraGicCode)
- Miro (mirogta)
- Nate McCurdy (natemccurdy)
- negast
- RampentPotato
- Ryan (vidkun)
- Steve Myers (stmyers)
- TheChuckMo

## License

Copyright (c) 2016-2018 Jorrit Folmer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Support

This is an open source project without warranty of any kind. No support is provided. However, a public repository and issue tracker are available at [https://github.com/jorritfolmer/puppet-splunk](https://github.com/jorritfolmer/puppet-splunk)
