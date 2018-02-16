# Parameter test coverage

## By version:

| version | tested | total |
|---------|--------|-------|
| v3.1.3  |   22   |  40   |
| v3.2.0  |   23   |  42   |
| v3.3.0  |   24   |  43   |
| v3.4.0  |   26   |  45   |
| v3.4.1  |   27   |  45   |
| v3.4.2  |   28   |  45   |
| v3.7.0  |   30   |  48   |
| v3.8.0  |   30   |  50   |
| v3.9.0  |   33   |  53   |

## By operating system:

| os      | tested | total |
|---------|--------|-------|
| linux   |   33   |  53   |
| windows |   0    |  53   |

## By parameter:

| parameter | rspec test |
|-----------|------------|
| `admin`     |  Y |
| `auth  => { authtype => 'LDAP'`    | Y |
| `auth  => { authtype => 'SAML``     | Y |
| `ciphersuite_intermediate` | no |
| `ciphersuite_modern` | no |
| `clustering => { mode => 'master'` | Y |
| `clustering => { mode => 'searchhead'` | Y |
| `clustering => { mode => 'slave'` | Y |
| `clustering => { indexer_discovery => true` | Y |
| `dhparamsize_intermediate` | no |
| `dhparamsize_modern` | no |
| `ds_intermediate` | Y |
| `ds` | Y |
| `ecdhcurvename_intermediate` | no |
| `ecdhcurvename_modern` | no |
| `httpport` | Y |
| `inputport`| Y |
| `kvstoreport`| Y |
| `lm`| Y |
| `maxbackupindex`| n |
| `maxfilesize`| n |
| `maxkbps`| y |
| `mgmthostport` | Y |
| `minfreespace` | no |
| `package_source` | yes |
| `pass4symmkey` | no |
| `phonehomeintervalinsec` | no |
| `replication_port`| Y |
| `repositorylocation`| Y |
| `requireclientcert`| Y |
| `reuse_puppet_certs`| Y |
| `rolemap` | no |
| `searchpeers`| Y |
| `secret`| Y |
| `service` | Y |
| `shclustering  => { mode => 'deployer'`| Y |
| `shclustering  => { mode => 'searchhead'`| Y |
| `splunk_bindip` | no |
| `splunk_db` | no |
| `splunk_os_user` | no |
| `splunk_os_group` | no |
| `sslcertpath`| Y |
| `sslcompatibility` | no |
| `sslpassword` | Y |
| `sslrootcapath` | Y |
| `sslverifyservercert` | Y |
| `sslversions_intermediate` | no |
| `sslversions_modern` | no |
| `tcpout` | Y |
| `tcpout` => 'indexer_discovery'`| Y |
| `type => 'uf'` | Y |
| `use_ack` | yes |
| `version` | no | 
