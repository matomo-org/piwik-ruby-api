$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support'
require 'active_support/core_ext'
require 'string'

%W{ 
  typecast api_scope base data_methods api_module api_response version
  seo referrers transitions user_country visit_time visitor_interest visits_summary
  user_settings annotations sites_manager users_manager
  actions live pdf_reports scheduled_reports image_graph
  provider visit_frequency multi_sites mobile_messaging
  custom_variables languages_manager goals example_api api
  site user events custom_dimensions
}.each { |r| require "piwik/#{r}" }

module Piwik
end