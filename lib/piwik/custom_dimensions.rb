module Piwik
  class CustomDimensions < ApiModule
    available_methods %W{
      getCustomDimension
      configureNewCustomDimension
      configureExistingCustomDimension
      getConfiguredCustomDimensions
      getAvailableScopes
      getAvailableExtractionDimensions
    }
  end
end