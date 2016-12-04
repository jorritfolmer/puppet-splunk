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

  context 'with searchpeers as array' do
    let(:params) { 
      {
        :searchpeers => [ 'splunk-idx1.internal.corp.tld:9997', 'splunk-idx2.internal.corp.tld:9997',],
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
  end

  context 'with searchpeers as string' do
    let(:params) { 
      {
        :searchpeers => 'splunk-idx1.internal.corp.tld:9997',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
  end

  context 'with deploymentserver' do
    let(:params) { 
      {
        :ds => 'splunk-idx1.internal.corp.tld:9997',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
        :dontruncmds => true,
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_deploymentclient_base/local/deploymentclient.conf').with_content(/targetUri = splunk-idx1.internal.corp.tld:9997/) }
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
    it { should contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(/cipherSuite = ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH\+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:\!aNULL:\!eNULL:\!EXPORT:\!DES:\!RC4:\!3DES:\!MD5:\!PSK/) }
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

end
