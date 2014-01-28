module Piwik
  class Referrers < ApiModule
    available_methods %W{
      getReferrerType
      getAll
      getKeywords
      getKeywordsForPageUrl
      getKeywordsForPageTitle
      getSearchEnginesFromKeywordId
      getSearchEngines
      getKeywordsFromSearchEngineId
      getCampaigns
      getKeywordsFromCampaignId
      getWebsites
      getUrlsFromWebsiteId
      getSocials
      getUrlsForSocial
      getNumberOfDistinctSearchEngines
      getNumberOfDistinctKeywords
      getNumberOfDistinctCampaigns
      getNumberOfDistinctWebsites
      getNumberOfDistinctWebsitesUrls
    }
  end
end
