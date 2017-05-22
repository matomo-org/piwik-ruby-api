require 'spec_helper'
describe 'Piwik::CustomDimensions' do
  before {
    stub_api_calls
  }
  
  let(:params) { {:idSite => 1, :period => 'day', :date => 'yesterday'} }
  subject { Piwik::CustomDimensions }
  
  assert_data_integrity(:get_custom_dimension, :size => 2)
  assert_data_integrity(:configure_new_custom_dimension, :size => 0)
  assert_data_integrity(:configure_existing_custom_dimension, :size => 1)
  assert_data_integrity(:get_configured_custom_dimensions, :size => 8)
  assert_data_integrity(:get_available_scopes, :size => 2)
  assert_data_integrity(:get_available_extraction_dimensions, :size => 3)
end