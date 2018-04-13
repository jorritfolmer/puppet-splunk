require 'spec_helper'

describe 'splunk' do

  context 'with defaults for all parameters' do
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should_not contain_file('/opt/splunk/etc/.ui_login') }
  end

  context 'with admin hash ' do
    let(:params) { 
      {
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/.ui_login') }
    it { should contain_file('/opt/splunk/etc/passwd') }
  end

  context 'with admin hash only ' do
    let(:params) { 
      {
        :admin => { 'hash' => 'zzzz', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/.ui_login') }
    it { should contain_file('/opt/splunk/etc/passwd') }
  end

  context 'with service ensured running' do
    let(:params) { 
      {
        :service => { 'ensure' => 'running'}
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should_not contain_file('/opt/splunk/etc/.ui_login') }
    it { should contain_service('splunk').with(
      'ensure' => 'running')
    }
  end

  context 'with service enable true' do
    let(:params) { 
      {
        :service => { 'enable' => true}
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should_not contain_file('/opt/splunk/etc/.ui_login') }
    it { should contain_service('splunk').with(
      'enable' => true)
    }
  end

  context 'with type=>uf' do
    let(:params) { 
      {
        :type => 'uf',
      }
    }
    it do
      should contain_package('splunkforwarder')
    end
  end

  context 'with package_source' do
    let(:params) { 
      {
        :package_source => 'https://download.splunk.com/products/splunk/releases/6.6.2/linux/splunk-6.6.2-4b804538c686-linux-2.6-x86_64.rpm'
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
  end

  context 'with tcpout as string' do
    let(:params) { 
      {
        :tcpout => 'splunk-idx.internal.corp.tld:9997',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/server = splunk-idx.internal.corp.tld:9997/) }
  end

  context 'with tcpout as string and use_ack' do
    let(:params) { 
      {
        :tcpout => 'splunk-idx.internal.corp.tld:9997',
        :use_ack => true,
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/useACK = true/) }
  end


  context 'with tcpout as string and revert to default splunk cert instead of puppet cert reuse' do
    let(:params) { 
      {
        :tcpout => 'splunk-idx.internal.corp.tld:9997',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :reuse_puppet_certs => false,
        :sslcertpath => 'server.pem',
        :sslrootcapath => 'cacert.pem',
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/sslRootCAPath = \/opt\/splunk\/etc\/auth\/cacert.pem/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/server = splunk-idx.internal.corp.tld:9997/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/sslCertPath = \/opt\/splunk\/etc\/auth\/server.pem/) }
  end

  context 'with tcpout as array' do
    let(:params) { 
      {
        :tcpout => [ 'splunk-idx1.internal.corp.tld:9997', 'splunk-idx2.internal.corp.tld:9997',],
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/server = splunk-idx1.internal.corp.tld:9997, splunk-idx2.internal.corp.tld:9997/) }
  end

  context 'with tcpout == indexer_discovery' do
    let(:params) { 
      {
        :tcpout => 'indexer_discovery',
        :clustering  => { 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.tld:8089' },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/indexerDiscovery = cluster/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/master_uri = https:\/\/splunk-cm.internal.corp.tld:8089/) }
    it { should_not contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf') }
  end

  context 'with indexer_discovery enabled on master' do
    let(:params) { 
      {
        :clustering  => { 'pass4symmkey' => 'changeme', 'mode' => 'master', 'indexer_discovery' => true, },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(/\[indexer_discovery\]/) }
  end

  context 'with universalforwarder and tcpout == indexer_discovery' do
    let(:params) { 
      {
        :type => 'uf',
        :tcpout => 'indexer_discovery',
        :clustering  => { 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.tld:8089' },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunkforwarder') }
    it { should contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/indexerDiscovery = cluster/) }
    it { should contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/master_uri = https:\/\/splunk-cm.internal.corp.tld:8089/) }
    it { should_not contain_file('/opt/splunkforwarder/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf') }
  end

  context 'with universalforwarder, tcpout == indexer_discovery but without cm' do
    let(:params) { 
      {
        :type => 'uf',
        :tcpout => 'indexer_discovery',
        :admin => { 'hash' => 'zzzz', },
      }
    }
    it { should compile.and_raise_error(/please set cluster master when using indexer_discovery/) }
  end

  context 'with searchpeers as array but without plaintext admin pass' do
    let(:params) { 
      {
        :searchpeers => [ 'splunk-idx1.internal.corp.tld:9997', 'splunk-idx2.internal.corp.tld:9997',],
        :admin => { 'hash' => 'zzzz', },
        :dontruncmds => true,
      }
    }
    it { should compile.and_raise_error(/Plaintext admin password is not set but required for adding search peers/) }
  end

  context 'with searchpeers as string and plaintext admin pass and hash' do
    let(:params) { 
      {
        :searchpeers => 'splunk-idx1.internal.corp.tld:9997',
        :admin => { 'pass' => 'plaintext', 'hash' => 'zzzz', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
  end

  context 'with searchpeers as string and plaintext admin pass without hash' do
    let(:params) { 
      {
        :searchpeers => 'splunk-idx1.internal.corp.tld:9997',
        :admin => { 'pass' => 'plaintext', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
  end

  context 'with deploymentserver' do
    let(:params) { 
      {
        :ds => 'splunk-ds.internal.corp.tld:8089',
        :admin => { 'hash' => 'zzzz', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_deploymentclient_base/local/deploymentclient.conf').with_content(/targetUri = splunk-ds.internal.corp.tld:8089/) }
  end

  context 'with inputs' do
    let(:params) { 
      {
        :inputport => 9997,
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(/\[splunktcp-ssl:9997\]/) }
  end

  context 'with inputs but with default splunk certs instead of puppet cert reuse' do
    let(:params) { 
      {
        :inputport => 9997,
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
        :reuse_puppet_certs => false,
        :sslcertpath => 'server.pem',
        :sslrootcapath => 'cacert.pem',
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/sslRootCAPath = \/opt\/splunk\/etc\/auth\/cacert.pem/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(/\[splunktcp-ssl:9997\]/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(/serverCert = \/opt\/splunk\/etc\/auth\/server.pem/) }
  end

  context 'with web' do
    let(:params) { 
      {
        :httpport => 8000,
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_web_base/local/web.conf').with_content(/httpport = 8000/) }
  end

  context 'without web' do
    let(:params) { 
      {
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_web_disabled/local/web.conf').with_content(/startwebserver = 0/) }
  end

  context 'with kvstore' do
    let(:params) { 
      {
        :kvstoreport => 8191,
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_kvstore_base/local/server.conf').with_content(/port = 8191/) }
  end

  context 'without kvstore' do
    let(:params) { 
      {
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_kvstore_disabled/local/server.conf').with_content(/disabled = true/) }
  end

  context 'with requireclientcert inputs ' do
    let(:params) { 
      {
        :inputport => 9997,
        :requireclientcert => 'inputs',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(/requireClientCert = true/) }
  end

  context 'with requireclientcert splunkd ' do
    let(:params) { 
      {
        :requireclientcert => 'splunkd',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/requireClientCert = true/) }
  end

  context 'with requireclientcert splunkd and inputs' do
    let(:params) { 
      {
        :inputport => 9997,
        :requireclientcert => ['splunkd','inputs'],
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/requireClientCert = true/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(/requireClientCert = true/) }
  end

  context 'with saml auth' do
    let(:params) { 
      {
        :auth  => { 'authtype' => 'SAML', 'saml_idptype' => 'ADFS', 'saml_idpurl' => 'https://sso.internal.corp.tld/adfs/ls', },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(/idpSLOUrl = https:\/\/sso.internal.corp.tld\/adfs\/ls\?wa=wsignout1.0/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(/idpSSOUrl = https:\/\/sso.internal.corp.tld\/adfs\/ls/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(/signatureAlgorithm = RSA-SHA256/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(/signAuthnRequest = true/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(/signedAssertion = true/) }
  end

  context 'with ldap auth' do
    let(:params) { 
      {
        :auth  => { 'authtype' => 'LDAP', 'ldap_host' => 'dc01.internal.corp.tld', 'ldap_binddn' => 'CN=sa_splunk,CN=Service Accounts,DC=internal,DC=corp,DC=tld', 'ldap_binddnpassword' => 'changeme'},
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_auth_ldap_base/local/authentication.conf').with_content(/bindDN = CN=sa_splunk,CN=Service Accounts,DC=internal,DC=corp,DC=tld/) }
  end

  context 'with ldap auth and nestedgroups enabled' do
    let(:params) { 
      {
        :auth  => { 'authtype' => 'LDAP', 'ldap_host' => 'dc01.internal.corp.tld', 'ldap_binddn' => 'CN=sa_splunk,CN=Service Accounts,DC=internal,DC=corp,DC=tld', 'ldap_binddnpassword' => 'changeme', 'ldap_nestedgroups' => 1},
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_auth_ldap_base/local/authentication.conf').with_content(/nestedGroups = 1/) }
  end

  context 'with license server' do
    let(:params) { 
      {
        :lm  => 'lm.internal.corp.tld:8089',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_license_client_base/local/server.conf').with_content(/master_uri = https:\/\/lm.internal.corp.tld:8089/) }
  end

  context 'with license server and pool suggestion' do
    let(:params) { 
      {
        :lm  => 'lm.internal.corp.tld:8089',
        :pool_suggestion => 'prodpool',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_license_client_base/local/server.conf').with_content(/master_uri = https:\/\/lm.internal.corp.tld:8089\npool_suggestion = prodpool/) }
  end

  context 'with splunk secret' do
    let(:params) { 
      {
        :secret  => 'somebase64string',
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/auth/splunk.secret').with_content(/somebase64string/) }
  end

  context 'with splunk secret for uf' do
    let(:params) { 
      {
        :secret  => 'somebase64string',
        :type  => 'uf',
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunkforwarder') }
    it { should contain_file('/opt/splunkforwarder/etc/auth/splunk.secret').with_content(/somebase64string/) }
  end

  context 'with default strong ssl' do
    let(:params) { 
      {
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    # the cipherSuite must be properly escaped, e.g. the + ! characters
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/cipherSuite = ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH\+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES256-GCM-SHA384:\!aNULL:\!eNULL:\!EXPORT:\!DES:\!RC4:\!3DES:\!MD5:\!PSK/) }
  end

  context 'with default splunk certs instead of puppet cert reuse' do
    let(:params) { 
      {
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
        :reuse_puppet_certs => false,
        :sslcertpath => 'server.pam',
        :sslrootcapath => 'cacert.pem',
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/sslRootCAPath = \/opt\/splunk\/etc\/auth\/cacert.pem/) }
  end

  context 'with nonstandard mgmthostport' do
    let(:params) { 
      {
        :dontruncmds => true,
        :mgmthostport => '127.0.0.1:9991',
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_mgmtport_base/local/web.conf').with_content(/\[settings\]\nmgmtHostPort = 127.0.0.1:9991/) }
  end

  context 'with mgmtport disable' do
    let(:params) { 
      {
        :dontruncmds => true,
        :mgmthostport => 'disable',
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_mgmtport_disabled/local/server.conf').with_content(/\[httpServer\]\ndisableDefaultPort = true/) }
  end

  context 'with cluster master role' do
    let(:params) { 
      {
        :clustering  => { 'mode' => 'master', 'pass4symmkey' => 'changeme', 'replication_factor' => 2, 'search_factor' => 2, },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(/mode = master/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(/pass4SymmKey = changeme/) }
  end

  context 'with cluster slave role' do
    let(:params) { 
      {
        :clustering  => { 'mode' => 'slave', 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.tld:8089' },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_slave_base/local/server.conf').with_content(/master_uri = https:\/\/splunk-cm.internal.corp.tld:8089/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(/pass4SymmKey = changeme/) }
  end

  context 'with cluster slave role and custom replication_port' do
    let(:params) { 
      {
        :clustering  => { 'mode' => 'slave', 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.tld:8089' },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
        :replication_port => 12345,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_slave_base/local/server.conf').with_content(/master_uri = https:\/\/splunk-cm.internal.corp.tld:8089/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(/pass4SymmKey = changeme/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_slave_base/local/server.conf').with_content(/\[replication_port:\/\/12345\]\ndisabled = false\n/) }
  end

  context 'with cluster searchhead role' do
    let(:params) { 
      {
        :clustering  => { 'mode' => 'searchhead', 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.tld:8089' },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_searchhead_base/local/server.conf').with_content(/master_uri = https:\/\/splunk-cm.internal.corp.tld:8089/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(/pass4SymmKey = changeme/) }
  end

  context 'with search head clustering' do
    let(:params) { 
      {
        :shclustering  => { 'mode' => 'searchhead', 'shd' => 'splunk-shd.internal.corp.tld:8089', 'label' => 'SHC' },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_base/default/server.conf').with_content(/conf_deploy_fetch_url = https:\/\/splunk-shd.internal.corp.tld:8089/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_base/default/server.conf').with_content(/\[replication_port:/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_base/default/server.conf').with_content(/shcluster_label = SHC/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_pass4symmkey_base/default/server.conf').with_content(/pass4SymmKey = /) }
  end

  context 'with search head deployer role' do
    let(:params) { 
      {
        :shclustering  => { 'mode' => 'deployer' },
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_pass4symmkey_base/local/server.conf').with_content(/pass4SymmKey = /) }
  end

  context 'with search head deployer role and pass4symmkey' do
    let(:params) { 
      {
        :shclustering  => { 'mode' => 'deployer', 'pass4symmkey' => 'SHCsecret'},
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_pass4symmkey_base/local/server.conf').with_content(/pass4SymmKey = SHCsecret/) }
  end

  context 'with multisite indexer clustering' do
    let(:params) { 
      {
        :clustering  => { 'mode' => 'master', 'thissite' => 'site1', 'available_sites' => 'site1,site2', 'site_replication_factor' => 'origin:1, total:2', 'site_search_factor' => 'origin:1, total:2'},
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(/multisite = true/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(/available_sites = site1,site2/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(/\[general\]\nsite = site1/) }
  end

  context 'with custom repositorylocation' do
    let(:params) { 
      {
        :ds => 'splunk-ds.internal.corp.tld:8089',
        :ds_intermediate => true,
        :repositorylocation => 'master-apps',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_deploymentclient_base/local/deploymentclient.conf').with_content(/repositoryLocation = \/opt\/splunk\/etc\/master-apps/) }
  end

  context 'with ds_intermediate set' do
    let(:params) { 
      {
        :ds => 'splunk-ds.internal.corp.tld:8089',
        :ds_intermediate => true,
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_deploymentclient_base/local/deploymentclient.conf').with_content(/repositoryLocation = \/opt\/splunk\/etc\/deployment-apps/) }
  end

  context 'with maxkbps set' do
    let(:params) { 
      {
        :type => 'uf',
        :maxkbps => 5000,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunkforwarder') }
    it { should contain_file('/opt/splunkforwarder/etc/apps/puppet_common_thruput_base/local/limits.conf').with_content(/\[thruput\]\nmaxKBps = 5000/) }
  end

  context 'with sslpassword set' do
    let(:params) { 
      {
        :inputport => 9997,
        :reuse_puppet_certs => false,
        :sslcertpath => 'server.pem',
        :sslrootcapath => 'cacert.pem',
        :sslpassword => 'password',
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(/sslPassword = password/) }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/sslPassword = password/) }
  end

  context 'with sslverifyservercert set' do
    let(:params) { 
      {
        :type => 'uf',
        :tcpout => 'server:9997',
        :sslcertpath => 'server.pem',
        :sslrootcapath => 'cacert.pem',
        :sslpassword => 'password',
        :sslverifyservercert => ['splunkd', 'outputs'],
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunkforwarder') }
    it { should contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(/sslVerifyServerCert = true/) }
    it { should contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/sslVerifyServerCert = true/) }
  end

end
