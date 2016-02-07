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
        :tcpout => 'splunk-idx.internal.corp.tld',
        :admin => { 'hash' => 'zzzz', 'fn' => 'yyyy', 'email' => 'wwww', },
      }
    }
    it { should contain_class('splunk::installed') }
    it { should contain_package('splunk') }
    it { should contain_file('/opt/splunk/etc/system/local/outputs.conf') }
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
    it { should contain_file('/opt/splunk/etc/system/local/outputs.conf') }
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
    it { should contain_augeas('/opt/splunk/etc/system/local/deploymentclient.conf deploymentServer') }
  end

end
