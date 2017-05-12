# Parameter test coverage

## By version:

| version | tested | total |
|---------|--------|-------|
| v3.1.3  |   22   |  40   |

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
| `minfreespace` | no |
| `pass4symmkey` | no |
| `phonehomeintervalinsec` | no |
| `replication_port`| Y |
| `repositorylocation`| Y |
| `reuse_puppet_certs`| Y |
| `rolemap` | no |
| `searchpeers`| Y |
| `service` | no |
| `shclustering  => { mode => 'deployer'`| Y |
| `shclustering  => { mode => 'searchhead'`| Y |
| `splunk_bindip` | no |
| `splunk_os_user` | no |
| `sslcertpath`| Y |
| `sslcompatibility` | no |
| `sslrootcapath`| Y |
| `sslversions_intermediate` | no |
| `sslversions_modern` | no |
| `tcpout`| Y |
| `type => 'uf'`| Y |
| `use_ack` | no |
| `version` | no | 
