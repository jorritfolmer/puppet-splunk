### 3.9.1

- Fixed issue where splunk first time run would happen before install

### 3.9.0

- Add setting to control maxKBps in limits.conf
- Add setting to control sslpassword plaintext or hashed
- Add setting to control sslverifyservercert for outputs and splunkd

### 3.8.0

- Add settings to control maxfilesize and rotation in log-local.cfg

### 3.7.0

- Add setting to control splunk.secret. (Issue #18)
- Add setting to control mgmtHostPort or disable the default Splunk management port (8089/tcp) entirely, e.g. on Universal Forwarders
- Add setting to control SPLUNK_DB. (Issue #5)
- Add additional LDAP authentication fields. (Issue #8)

### 3.6.0

- Add settings to allow forwarders to fail over between indexers in multiple sites.

### 3.5.0

- Added the optional 'nestedGroups' setting for LDAP authentication.

### 3.4.3

- Added explicit error when using indexer_discovery without setting cm

### 3.4.2

- Fixed service status confusion (Issue #16)

### 3.4.1

- Added package_source for Linux in repository-less environments
- Perform first-time-run after an upgrade
- Fix boot-start for older Splunk UF versions
- Add ssl3 to intermediate_compatibility due to SPL-141961 and SPL-141964

### 3.4.0

- Added indexer discovery

### 3.3.0

- Added requireclientcert
- Successfully verified compatibility with Puppet 5.0.0 (Ruby 2.4) through Travis

### 3.2.0

- Added support for Windows

### 3.1.3

- Fixed typo in ds_intermediate parameter (Issue #11)
- Added forgotten ecdhcurvename_intermediate parameter (Issue #11)
- Removed obsolete use_certs parameter (Issue #11)
- Added TEST_COVERAGE.md

### 3.1.2

- Fixed forgotten repositorylocation (issue #9)
- Added instructions to generate SHA512 password hashes (Issue #10)
- Updated arrows to follow Puppet style guide

### 3.1.1

- Fixed typo in Puppet SSL directory pathname

### 3.1.0

- Added minfreespace parameter
- Fixed metadata.json
- Fixed hardcoded ecdhcurve

### 3.0.2

- Changed curve to secp384r1 to support Chrome
- Added AES256-GCM-SHA384 to cipherlist because mongod doesn't support curves and fails client helo's from Splunk. These failures appeared with Splunk 6.5.x

### 3.0.1

- Fixed failing ca.crt reuse from open-source Puppet

### 3.0.0

- Added support for multisite indexer clustering
- Added replication_port parameter to configure index cluster replication port.
- Moved useACK paramter to use_ack due to [Puppet stricter language check](https://docs.puppet.com/puppet/latest/reference/lang_reserved.html#parameters)

### 2.1.2

- Improved SAML support and updated settings for Splunk 6.4 and Splunk 6.5

### 2.1.1

- Improved search head clustering (SHC) support: Puppet now only places the initial SHC node configuration, and won't touch it afterwards. This allows the SH deployer to take over after initial configuration. A staging SHC instance is no longer necessary.
- Improved search head clustering (SHC) support: `splunk init shcluster` is no longer necessary, only `splunk bootstrap shcluster-captain`

### 2.1.0

- Added search head clustering (SHC) support, although only useful for staging purposes due to the overruling nature of the search head deployer (SHD)
- Added support to reuse Puppet certs from /etc/puppetlabs/puppet/ssl whenever commercial Puppet is used.

### 2.0.0

- Moved Splunk configuration out of etc/system/local to individual Splunk config apps
- Add LDAP authentication support 

### 1.0.9

- Added phonehomeintervalinsec parameter to configure phoneHomeIntervalInSec for the deploymentclient

### 1.0.8

- Improved adding search peers
- Added class containment, to properly support `require =>` from other resources or classes. This add a dependency on puppetlabs-stdlib.

### 1.0.7

- Added rpsec tests
- Added github->travis-ci integration
- Fixed issues for Puppet 2.7

### 1.0.6

- Add SAML authentication support through ADFS as IdP

### 1.0.5

- Specify IP to bind to

### 1.0.4

- Optionally specify Splunk version to install
- Merged PR #1 from @timidri

### 1.0.3

- Added `ds_intermediate` parameter to create a deployment server that can deploy apps from an another upstream deployment server.

### 1.0.2

- Added `use_ack` parameter to manage indexer acknowledgement
- Updated README with Debian / Ubuntu prerequisites.

### 1.0.1

- Added `service` parameter to manage start and running state of the Splunk or Splunkforwarder service.

### 1.0.0

Initial release: 

- License master
- Splunk web
- Standalone search head
- KVstore
- Standalone indexer
- Deployment server
- Deployment client
- Distributed search
- Forwarding with load-balancing
- Data input with SSL
- Index clustering: cluster master
- Index clustering: cluster peer
- Index clustering: search head
