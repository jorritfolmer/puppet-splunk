require 'spec_helper_acceptance'

describe 'splunk class' do
  context 'with default parameters' do
    # Using puppet_apply as a helper
    it 'works with no errors' do
      pp = <<-MANIFEST
      class { 'splunk': }
      MANIFEST

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end