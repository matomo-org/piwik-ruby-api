module Piwik
  class Events < ApiModule
    available_methods %W{
      getCategory
      getAction
      getName
      getActionFromCategoryId
      getNameFromCategoryId
      getCategoryFromActionId
      getNameFromActionId
      getActionFromNameId
      getCategoryFromNameId
    }
  end
end