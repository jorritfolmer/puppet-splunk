require 'spec_helper'

describe 'splunk' do
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.not_to contain_file('/opt/splunk/etc/.ui_login') }
  end

  context 'with admin hash ' do
    let(:params) do
      {
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/.ui_login') }
    it { is_expected.to contain_file('/opt/splunk/etc/passwd') }
  end

  context 'with admin hash only ' do
    let(:params) do
      {
        admin: { 'hash' => 'zzzz' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/.ui_login') }
    it { is_expected.to contain_file('/opt/splunk/etc/passwd') }
  end

  context 'with service ensured running' do
    let(:params) do
      {
        service: { 'ensure' => 'running' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.not_to contain_file('/opt/splunk/etc/.ui_login') }
    it {
      is_expected.to contain_service('splunk').with(
        'ensure' => 'running',
      )
    }
  end

  context 'with service enable true' do
    let(:params) do
      {
        service: { 'enable' => true },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.not_to contain_file('/opt/splunk/etc/.ui_login') }
    it {
      is_expected.to contain_service('splunk').with(
        'enable' => true,
      )
    }
  end

  context 'with type=>uf' do
    let(:params) do
      {
        type: 'uf',
      }
    end

    it do
      is_expected.to contain_package('splunkforwarder')
    end
  end

  context 'with package_source' do
    let(:params) do
      {
        package_source: 'https://download.splunk.com/products/splunk/releases/6.6.2/linux/splunk-6.6.2-4b804538c686-linux-2.6-x86_64.rpm',
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
  end

  context 'with tcpout as string' do
    let(:params) do
      {
        tcpout: 'splunk-idx.internal.corp.example:9997',
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{server = splunk-idx.internal.corp.example:9997}) }
  end

  context 'with tcpout as string and use_ack' do
    let(:params) do
      {
        tcpout: 'splunk-idx.internal.corp.example:9997',
        use_ack: true,
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{useACK = true}) }
  end

  context 'with tcpout as string and revert to default splunk cert instead of puppet cert reuse' do
    let(:params) do
      {
        tcpout: 'splunk-idx.internal.corp.example:9997',
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        reuse_puppet_certs: false,
        sslcertpath: 'server.pem',
        sslrootcapath: 'cacert.pem',
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(%r{sslRootCAPath = /opt/splunk/etc/auth/cacert.pem}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{server = splunk-idx.internal.corp.example:9997}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{sslCertPath = /opt/splunk/etc/auth/server.pem}) }
  end

  context 'with reuse_puppet_certs_for_web' do
    let(:params) do
      {
        httpport: 8000,
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        reuse_puppet_certs_for_web: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/auth/certs/webprivkey.pem') }
    it { is_expected.to contain_file('/opt/splunk/etc/auth/certs/webcert.pem') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_web_base/local/web.conf').with_content(%r{privKeyPath = /opt/splunk/etc/auth/certs/webprivkey.pem}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_web_base/local/web.conf').with_content(%r{serverCert = /opt/splunk/etc/auth/certs/webcert.pem}) }
  end

  context 'with tcpout as array' do
    let(:params) do
      {
        tcpout: ['splunk-idx1.internal.corp.example:9997', 'splunk-idx2.internal.corp.example:9997'],
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it {
      is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf')
        .with_content(%r{server = splunk-idx1.internal.corp.example:9997, splunk-idx2.internal.corp.example:9997})
    }
  end

  context 'with tcpout == indexer_discovery' do
    let(:params) do
      {
        tcpout: 'indexer_discovery',
        clustering: { 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.example:8089' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{indexerDiscovery = cluster}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{master_uri = https://splunk-cm.internal.corp.example:8089}) }
    it { is_expected.not_to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf') }
  end

  context 'with indexer_discovery enabled on master' do
    let(:params) do
      {
        clustering: { 'pass4symmkey' => 'changeme', 'mode' => 'master', 'indexer_discovery' => true },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(%r{\[indexer_discovery\]}) }
  end

  context 'with universalforwarder and tcpout == indexer_discovery' do
    let(:params) do
      {
        type: 'uf',
        tcpout: 'indexer_discovery',
        clustering: { 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.example:8089' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunkforwarder') }
    it { is_expected.to contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{indexerDiscovery = cluster}) }
    it { is_expected.to contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{master_uri = https://splunk-cm.internal.corp.example:8089}) }
    it { is_expected.not_to contain_file('/opt/splunkforwarder/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf') }
  end

  context 'with universalforwarder, tcpout == indexer_discovery but without cm' do
    let(:params) do
      {
        type: 'uf',
        tcpout: 'indexer_discovery',
        admin: { 'hash' => 'zzzz' },
      }
    end

    it { is_expected.to compile.and_raise_error(%r{please set cluster master when using indexer_discovery}) }
  end

  context 'with searchpeers as array but without plaintext admin pass' do
    let(:params) do
      {
        searchpeers: ['splunk-idx1.internal.corp.example:9997', 'splunk-idx2.internal.corp.example:9997'],
        admin: { 'hash' => 'zzzz' },
        dontruncmds: true,
      }
    end

    it { is_expected.to compile.and_raise_error(%r{Plaintext admin password is not set but required for adding search peers}) }
  end

  context 'with searchpeers as string and plaintext admin pass and hash' do
    let(:params) do
      {
        searchpeers: 'splunk-idx1.internal.corp.example:9997',
        admin: { 'pass' => 'plaintext', 'hash' => 'zzzz' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
  end

  context 'with searchpeers as string and plaintext admin pass without hash' do
    let(:params) do
      {
        searchpeers: 'splunk-idx1.internal.corp.example:9997',
        admin: { 'pass' => 'plaintext' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
  end

  context 'with deploymentserver' do
    let(:params) do
      {
        ds: 'splunk-ds.internal.corp.example:8089',
        admin: { 'hash' => 'zzzz' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_deploymentclient_base/local/deploymentclient.conf').with_content(%r{targetUri = splunk-ds.internal.corp.example:8089}) }
  end

  context 'with inputs' do
    let(:params) do
      {
        inputport: 9997,
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(%r{\[splunktcp-ssl:9997\]}) }
  end

  context 'with inputs but with default splunk certs instead of puppet cert reuse' do
    let(:params) do
      {
        inputport: 9997,
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
        reuse_puppet_certs: false,
        sslcertpath: 'server.pem',
        sslrootcapath: 'cacert.pem',
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(%r{sslRootCAPath = /opt/splunk/etc/auth/cacert.pem}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(%r{\[splunktcp-ssl:9997\]}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(%r{serverCert = /opt/splunk/etc/auth/server.pem}) }
  end

  context 'with web' do
    let(:params) do
      {
        httpport: 8000,
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_web_base/local/web.conf').with_content(%r{httpport = 8000}) }
  end

  context 'without web' do
    let(:params) do
      {
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_web_disabled/local/web.conf').with_content(%r{startwebserver = 0}) }
  end

  context 'with kvstore' do
    let(:params) do
      {
        kvstoreport: 8191,
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_kvstore_base/local/server.conf').with_content(%r{port = 8191}) }
  end

  context 'without kvstore' do
    let(:params) do
      {
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_kvstore_disabled/local/server.conf').with_content(%r{disabled = true}) }
  end

  context 'with requireclientcert inputs ' do
    let(:params) do
      {
        inputport: 9997,
        requireclientcert: 'inputs',
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(%r{requireClientCert = true}) }
  end

  context 'with requireclientcert splunkd ' do
    let(:params) do
      {
        requireclientcert: 'splunkd',
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(%r{requireClientCert = true}) }
  end

  context 'with requireclientcert splunkd and inputs' do
    let(:params) do
      {
        inputport: 9997,
        requireclientcert: ['splunkd', 'inputs'],
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(%r{requireClientCert = true}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(%r{requireClientCert = true}) }
  end

  context 'with saml auth' do
    let(:params) do
      {
        auth: { 'authtype' => 'SAML', 'saml_idptype' => 'ADFS', 'saml_idpurl' => 'https://sso.internal.corp.example/adfs/ls' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it {
      is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf')
        .with_content(%r{idpSLOUrl = https://sso.internal.corp.example/adfs/ls?wa=wsignout1.0})
    }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(%r{idpSSOUrl = https://sso.internal.corp.example/adfs/ls}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(%r{signatureAlgorithm = RSA-SHA256}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(%r{signAuthnRequest = true}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_auth_saml_base/local/authentication.conf').with_content(%r{signedAssertion = true}) }
  end

  context 'with ldap auth' do
    let(:params) do
      {
        auth: {
          'authtype' => 'LDAP',
          'ldap_host' => 'dc01.internal.corp.example',
          'ldap_binddn' => 'CN=sa_splunk,CN=Service Accounts,DC=internal,DC=corp,DC=tld',
          'ldap_binddnpassword' => 'changeme',
        },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it {
      is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_auth_ldap_base/local/authentication.conf')
        .with_content(%r{bindDN = CN=sa_splunk,CN=Service Accounts,DC=internal,DC=corp,DC=tld})
    }
  end

  context 'with ldap auth and nestedgroups enabled' do
    let(:params) do
      {
        auth: {
          'authtype' => 'LDAP',
          'ldap_host' => 'dc01.internal.corp.example',
          'ldap_binddn' => 'CN=sa_splunk,CN=Service Accounts,DC=internal,DC=corp,DC=tld',
          'ldap_binddnpassword' => 'changeme',
          'ldap_nestedgroups' => 1,
        },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_auth_ldap_base/local/authentication.conf').with_content(%r{nestedGroups = 1}) }
  end

  context 'with license server' do
    let(:params) do
      {
        lm: 'lm.internal.corp.example:8089',
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_license_client_base/local/server.conf').with_content(%r{master_uri = https://lm.internal.corp.example:8089}) }
  end

  context 'with license server and pool suggestion' do
    let(:params) do
      {
        lm: 'lm.internal.corp.example:8089',
        pool_suggestion: 'prodpool',
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it {
      is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_license_client_base/local/server.conf')
        .with_content(%r{master_uri = https://lm.internal.corp.example:8089\npool_suggestion = prodpool})
    }
  end

  context 'with splunk secret' do
    let(:params) do
      {
        secret: 'somebase64string',
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/auth/splunk.secret').with_content(%r{somebase64string}) }
  end

  context 'with splunk secret for uf' do
    let(:params) do
      {
        secret: 'somebase64string',
        type: 'uf',
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunkforwarder') }
    it { is_expected.to contain_file('/opt/splunkforwarder/etc/auth/splunk.secret').with_content(%r{somebase64string}) }
  end

  context 'with default strong ssl' do
    let(:params) do
      {
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    # the cipherSuite must be properly escaped, e.g. the + ! characters
    # rubocop:disable Metrics/LineLength
    it {
      is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf')
        .with_content(%r{cipherSuite = ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH\+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES256-GCM-SHA384:\!aNULL:\!eNULL:\!EXPORT:\!DES:\!RC4:\!3DES:\!MD5:\!PSK})
    }
    # rubocop:enable Metrics/LineLength
  end

  context 'with default splunk certs instead of puppet cert reuse' do
    let(:params) do
      {
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
        reuse_puppet_certs: false,
        sslcertpath: 'server.pam',
        sslrootcapath: 'cacert.pem',
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(%r{sslRootCAPath = /opt/splunk/etc/auth/cacert.pem}) }
  end

  context 'with nonstandard mgmthostport' do
    let(:params) do
      {
        dontruncmds: true,
        mgmthostport: '127.0.0.1:9991',
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_mgmtport_base/local/web.conf').with_content(%r{\[settings\]\nmgmtHostPort = 127.0.0.1:9991}) }
  end

  context 'with mgmtport disable' do
    let(:params) do
      {
        dontruncmds: true,
        mgmthostport: 'disable',
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_mgmtport_disabled/local/server.conf').with_content(%r{\[httpServer\]\ndisableDefaultPort = true}) }
  end

  context 'with cluster master role' do
    let(:params) do
      {
        clustering: { 'mode' => 'master', 'pass4symmkey' => 'changeme', 'replication_factor' => 2, 'search_factor' => 2 },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(%r{mode = master}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(%r{pass4SymmKey = changeme}) }
  end

  context 'with cluster slave role' do
    let(:params) do
      {
        clustering: { 'mode' => 'slave', 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.example:8089' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_slave_base/local/server.conf').with_content(%r{master_uri = https://splunk-cm.internal.corp.example:8089}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(%r{pass4SymmKey = changeme}) }
  end

  context 'with cluster slave role and custom replication_port' do
    let(:params) do
      {
        clustering: { 'mode' => 'slave', 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.example:8089' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
        replication_port: 12_345,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_slave_base/local/server.conf').with_content(%r{master_uri = https://splunk-cm.internal.corp.example:8089}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(%r{pass4SymmKey = changeme}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_slave_base/local/server.conf').with_content(%r{[replication_port://12345]\ndisabled = false\n}) }
  end

  context 'with cluster searchhead role' do
    let(:params) do
      {
        clustering: { 'mode' => 'searchhead', 'pass4symmkey' => 'changeme', 'cm' => 'splunk-cm.internal.corp.example:8089' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_searchhead_base/local/server.conf').with_content(%r{master_uri = https://splunk-cm.internal.corp.example:8089}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_pass4symmkey_base/local/server.conf').with_content(%r{pass4SymmKey = changeme}) }
  end

  context 'with search head clustering' do
    let(:params) do
      {
        shclustering: { 'mode' => 'searchhead', 'shd' => 'splunk-shd.internal.corp.example:8089', 'label' => 'SHC' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_base/default/server.conf').with_content(%r{conf_deploy_fetch_url = https://splunk-shd.internal.corp.example:8089}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_base/default/server.conf').with_content(%r{\[replication_port:}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_base/default/server.conf').with_content(%r{shcluster_label = SHC}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_pass4symmkey_base/default/server.conf').with_content(%r{pass4SymmKey = }) }
  end

  context 'with search head deployer role' do
    let(:params) do
      {
        shclustering: { 'mode' => 'deployer' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_pass4symmkey_base/local/server.conf').with_content(%r{pass4SymmKey = }) }
  end

  context 'with search head deployer role and pass4symmkey' do
    let(:params) do
      {
        shclustering: { 'mode' => 'deployer', 'pass4symmkey' => 'SHCsecret' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_search_shcluster_pass4symmkey_base/local/server.conf').with_content(%r{pass4SymmKey = SHCsecret}) }
  end

  context 'with multisite indexer clustering' do
    let(:params) do
      {
        clustering: { 'mode' => 'master', 'thissite' => 'site1', 'available_sites' => 'site1,site2', 'site_replication_factor' => 'origin:1, total:2', 'site_search_factor' => 'origin:1, total:2' },
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(%r{multisite = true}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(%r{available_sites = site1,site2}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_indexer_cluster_master_base/local/server.conf').with_content(%r{\[general\]\nsite = site1}) }
  end

  context 'with custom repositorylocation' do
    let(:params) do
      {
        ds: 'splunk-ds.internal.corp.example:8089',
        ds_intermediate: true,
        repositorylocation: 'master-apps',
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_deploymentclient_base/local/deploymentclient.conf').with_content(%r{repositoryLocation = /opt/splunk/etc/master-apps}) }
  end

  context 'with ds_intermediate set' do
    let(:params) do
      {
        ds: 'splunk-ds.internal.corp.example:8089',
        ds_intermediate: true,
        admin: { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww' },
        dontruncmds: true,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_deploymentclient_base/local/deploymentclient.conf').with_content(%r{repositoryLocation = /opt/splunk/etc/deployment-apps}) }
  end

  context 'with maxkbps set' do
    let(:params) do
      {
        type: 'uf',
        maxkbps: 5000,
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunkforwarder') }
    it { is_expected.to contain_file('/opt/splunkforwarder/etc/apps/puppet_common_thruput_base/local/limits.conf').with_content(%r{\[thruput\]\nmaxKBps = 5000}) }
  end

  context 'with sslpassword set' do
    let(:params) do
      {
        inputport: 9997,
        reuse_puppet_certs: false,
        sslcertpath: 'server.pem',
        sslrootcapath: 'cacert.pem',
        sslpassword: 'password',
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunk') }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_inputs/local/inputs.conf').with_content(%r{sslPassword = password}) }
    it { is_expected.to contain_file('/opt/splunk/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(%r{sslPassword = password}) }
  end

  context 'with sslverifyservercert set' do
    let(:params) do
      {
        type: 'uf',
        tcpout: 'server:9997',
        sslcertpath: 'server.pem',
        sslrootcapath: 'cacert.pem',
        sslpassword: 'password',
        sslverifyservercert: ['splunkd', 'outputs'],
      }
    end

    it { is_expected.to contain_class('splunk::installed') }
    it { is_expected.to contain_package('splunkforwarder') }
    it { is_expected.to contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_outputs/local/outputs.conf').with_content(%r{sslVerifyServerCert = true}) }
    it { is_expected.to contain_file('/opt/splunkforwarder/etc/apps/puppet_common_ssl_base/local/server.conf').with_content(%r{sslVerifyServerCert = true}) }
  end
end
