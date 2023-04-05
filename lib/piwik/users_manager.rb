module Piwik
  class UsersManager < ApiModule
    available_methods %W{
      setUserPreference
      getUserPreference
      getUsers
      getUsersLogin
      getUsersSitesFromAccess
      getUsersAccessFromSite
      getUsersWithSiteAccess
      getSitesAccessFromUser
      getUser
      getUserByEmail
      addUser
      updateUser
      deleteUser
      userExists
      userEmailExists
      setUserAccess
      createAppSpecificTokenAuth
    }
    
    def self.get params
      resp = self.get_user(params)
      raise Piwik::UnknownUser if resp.blank?
      Piwik::User.new resp
    end
    
    # monkeypatching, as the Piwik API is inconsistent.
    # not all add methods return the same response type. Boo.
    def self.add params
      obj = Piwik::User.new(params)
      resp = self.api_call('addUser',params)
      obj
    end
    
    def self.save params
      self.api_call('updateUser',params)
    end
    
    def self.delete params
      self.api_call('deleteDelete',params)
    end
    
    # TODO: this one is not working. 
    # I assume there are other metacoded methods that might throw errors, 
    # so a bit or hunting down is in ortder sometime
    def self.user_exists(params)
      Piwik::UsersManager::UserExists.new(:value => self.api_call('userExists',params))
    end
  end
end