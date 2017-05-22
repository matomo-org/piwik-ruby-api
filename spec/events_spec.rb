require 'spec_helper'
describe 'Piwik::Events' do
  before {
    stub_api_calls
  }
  
  let(:params) { {:idSite => 1, :period => 'day', :date => 'yesterday'} }
  subject { Piwik::Events }
  
  assert_data_integrity(:get_category, :size => 11)
  assert_data_integrity(:get_action, :size => 2)
  assert_data_integrity(:get_name, :size => 10)
  assert_data_integrity(:get_action_from_category_id, :size => 2)
  assert_data_integrity(:get_name_from_category_id, :size => 10)
  assert_data_integrity(:get_category_from_action_id, :size => 11)
  assert_data_integrity(:get_name_from_action_id, :size => 10)
  assert_data_integrity(:get_action_from_name_id, :size => 2)
  assert_data_integrity(:get_category_from_name_id, :size => 11)
end