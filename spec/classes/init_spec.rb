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
end
