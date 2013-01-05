module Piwik
  class Site < Piwik::Base
    attr_accessor :name, :main_url
    attr_reader :id, :created_at, :config
    
    # Initializes a new <tt>Piwik::Site</tt> object, with the supplied attributes. 
    # 
    # You can pass the URL for your Piwik install and an authorization token as 
    # the second and third parameters. If you don't, than it will try to find 
    # them in a <tt>'~/.piwik'</tt> or <tt>RAILS_ROOT/config/piwik.yml</tt> 
    # (and create the file with an empty template if it doesn't exists).
    # 
    # Valid (and required) attributes are:
    # * <tt>:name</tt> - the site's name
    # * <tt>:main_url</tt> - the site's url
    def initialize(attributes={}, piwik_url=nil, auth_token=nil)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      @config = if piwik_url.nil? || auth_token.nil?
        self.class.load_config
      else
        {:piwik_url => piwik_url, :auth_token => auth_token}
      end
      load_attributes(attributes)
    end
  
    # Returns an instance of <tt>Piwik::Site</tt> representing the site identified by 
    # the supplied <tt>site_id</tt>. Raises a <tt>Piwik::ApiError</tt> if the site doesn't 
    # exists or if the user associated with the supplied auth_token does not 
    # have at least 'view' access to the site.
    # 
    # You can pass the URL for your Piwik install and an authorization token as 
    # the second and third parameters. If you don't, than it will try to find 
    # them in a <tt>'~/.piwik'</tt> (and create the file with an empty template if it 
    # doesn't exists).
    def self.load(site_id, piwik_url=nil, auth_token=nil)
      raise ArgumentError, "expected a site Id" if site_id.nil?
      @config = if piwik_url.nil? || auth_token.nil?
        load_config
      else
        {:piwik_url => piwik_url, :auth_token => auth_token}
      end
      attributes = get_site_attributes_by_id(site_id, @config[:piwik_url], @config[:auth_token])
      new(attributes, @config[:piwik_url], @config[:auth_token])
    end
    
    # Returns <tt>true</tt> if the current site does not exists in the Piwik yet.
    def new?
      id.nil? && created_at.nil?
    end
    
    # Saves the current site in Piwik.
    # 
    # Calls <tt>create</tt> it it's a new site, <tt>update</tt> otherwise.
    def save
      new? ? create : update
    end
    
    # Saves the current new site in Piwik.
    # 
    # Equivalent Piwik API call: SitesManager.addSite (siteName, urls)
    def create
      raise ArgumentError, "Site already exists in Piwik, call 'update' instead" unless new?
      raise ArgumentError, "Name can not be blank" if name.blank?
      raise ArgumentError, "Main URL can not be blank" if main_url.blank?
      result = call('SitesManager.addSite', :siteName => name, :urls => main_url)
      @id = result['value'].to_i
      @created_at = Time.current
      id && id > 0 ? true : false
    end
    
    # Saves the current site in Piwik, updating it's data.
    # 
    # Equivalent Piwik API call: SitesManager.updateSite (idSite, siteName, urls)
    def update
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      raise ArgumentError, "Name can not be blank" if name.blank?
      raise ArgumentError, "Main URL can not be blank" if main_url.blank?
      result = call('SitesManager.updateSite', :idSite => id, :siteName => name, :urls => main_url)
      result['result'] == 'success' ? true : false
    end
    
    def reload
      #TODO
    end
    
    # Deletes the current site from Piwik.
    # 
    # Equivalent Piwik API call: SitesManager.deleteSite (idSite)
    def destroy
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('SitesManager.deleteSite', :idSite => id)
      #puts "\n destroy #{result} \n"
      freeze
      result['result'] == 'success' ? true : false
    end
    
    # Gives read access (<tt>'view'</tt>) to the supplied user login for the current
    # site.
    def give_view_access_to(login)
      give_access_to(:view, login)
    end
    
    # Gives read and write access (<tt>'admin'</tt>) for the supplied user login for the 
    # current site.
    def give_admin_access_to(login)
      give_access_to(:admin, login)
    end
    
    # Removes all access (gives an <tt>'noaccess'</tt>) for the supplied user login for 
    # the current site.
    def give_no_access_to(login)
      give_access_to(:noaccess, login)
    end
    alias_method :remove_access_from, :give_no_access_to


    # Returns a hash with a summary of access information for the current site 
    # (visits, unique visitors, actions / pageviews, maximum actions per visit, 
    # bounces and total time spent in all visits in seconds), filtered by the 
    # supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.get (idSite, period, date)
    def summary(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('VisitsSummary.get', :idSite => id, :period => period, :date => date)
      {
        :visits => result['nb_visits'].to_i,
        :unique_visitors => result['nb_uniq_visitors'].to_i,
        :actions => result['nb_actions'].to_i,
        :max_actions_per_visit => result['max_actions'].to_i,
        :bounces => result['bounce_count'].to_i,
        :total_time_spent => result['sum_visit_length'].to_i, # in seconds
      }
    end
    
    # Returns the amount of visits for the current site, filtered by the 
    # supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.getVisits (idSite, period, date)
    def visits(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('VisitsSummary.getVisits', :idSite => id, :period => period, :date => date)
      result['value']
    end
    
    # Returns the amount of unique visitors for the current site, filtered by 
    # the supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.getUniqueVisitors (idSite, period, date)
    def unique_visitors(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('VisitsSummary.getUniqueVisitors', :idSite => id, :period => period, :date => date)
      result['value']
    end
    
    # Returns the amount of actions (pageviews) for the current site, filtered 
    # by the supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.getActions (idSite, period, date)
    def actions(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('VisitsSummary.getActions', :idSite => id, :period => period, :date => date)
      result['value']
    end
    alias_method :pageviews, :actions

    # Returns a string with the javascript tracking code for the current site.
    # 
    # Equivalent Piwik API call: SitesManager.getJavascriptTag (idSite)
    def get_javascript_tag
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('SitesManager.getJavascriptTag', :idSite => id)
      #puts "get_javascript_tag #{result.to_s}"
      result['value']
    end    

    # Returns a big Array of Hashes with all page titles along with standard Actions metrics for each row, for the current site.
    #
    # Example result:
    # => [{"label"=>" Izdelava spletnih strani | Spletnik d.o.o.", "nb_visits"=>36, "nb_uniq_visitors"=>35, "nb_hits"=>41, "sum_time_spent"=>240, "entry_nb_uniq_visitors"=>"33", "entry_nb_visits"=>"36", "entry_nb_actions"=>"92", "entry_sum_visit_length"=>"3422", "entry_bounce_count"=>"20", "exit_nb_uniq_visitors"=>"19", "exit_nb_visits"=>"22", "avg_time_on_page"=>7, "bounce_rate"=>"56%", "exit_rate"=>"61%"}]
    #
    # Equivalent Piwik API call: Actions.getPageTitles (idSite, period, date, segment = '', expanded = '', idSubtable = '')
    def get_page_titles(params={})
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('Actions.getPageTitles', {:idSite => id, :period => :day, :date => Date.today, :segment => '', :expanded => '', :idSubtable => ''}.update(params))
      #puts "get_page_titles: #{result}"
      result
    end

    # Returns a big Array of Hashes with all page urls along with standard Actions metrics for each row, for the current site.
    #
    # Example result:
    # => [{"label"=>"spletnik", "nb_visits"=>69, "nb_hits"=>87, "sum_time_spent"=>4762, "entry_nb_visits"=>40, "entry_nb_actions"=>101, "entry_sum_visit_length"=>6752, "entry_bounce_count"=>26, "exit_nb_visits"=>39, "avg_time_on_page"=>69, "bounce_rate"=>"65%", "exit_rate"=>"57%", "idsubdatatable"=>1}]
    #
    # Example call:
    #  
    # Piwik::Site.load(203).get_page_urls(:expanded=>1)
    #
    # Equivalent Piwik API call: Actions.getPageUrls (idSite, period, date, segment = '', expanded = '', idSubtable = '')
    def get_page_urls(params={})
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('Actions.getPageUrls', { :idSite => id, :period => :day, :date => Date.today, :segment => '', :expanded => '', :idSubtable => '' }.update(params))
      #puts "get_page_urls: #{result}"
      result
    end

    def bounce_count(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('VisitsSummary.getBounceCount', :idSite => id, :period => period, :date => date)
      result['value']
    end

    def sum_visits_length(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      result = call('VisitsSummary.getSumVisitsLength', :idSite => id, :period => period, :date => date)
      result['value']
    end

    def website_referrers(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      call('Referers.getWebsites', :idSite => id, :period => period, :date => date)
    end

    private
      # Loads the attributes in the instance variables.
      def load_attributes(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @main_url = attributes[:main_url] ? attributes[:main_url].gsub(/\/$/, '') : nil
        @created_at = attributes[:created_at]
      end

      # Gives the supplied access for the supplied user, for the current site.
      # 
      # * <tt>access</tt> can be one of <tt>:view</tt>, <tt>:admin</tt> or <tt>:noaccess</tt>
      # * <tt>login</tt> is the user login on Piwik
      # 
      # Equivalent Piwik API call: UsersManager.setUserAccess (userLogin, access, idSites)
      def give_access_to(access, login)
        raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
        result = call('UsersManager.setUserAccess', :idSites => id, :access => access.to_s, :userLogin => login.to_s)
        #result['success'] ? true : false
        result['result'] == 'success' ? true : false  
      end

      # Returns a hash with the attributes of the supplied site, identified 
      # by it's Id in <tt>site_id</tt>.
      # 
      # Equivalent Piwik API call: SitesManager.getSiteFromId (idSite)
      def self.get_site_attributes_by_id(site_id, piwik_url, auth_token)
        result = call('SitesManager.getSiteFromId', {:idSite => site_id}, piwik_url, auth_token)
        #puts "get_site_attributes_by_id #{result.to_s}"
        raise UnknownSite, "Site not existent in Piwik" if result.kind_of?(Hash) && result['value'] == false
        attributes = {
          :id => result[0]['idsite'].to_i,
          :name => result[0]['name'],
          :main_url => result[0]['main_url'],
          :created_at => Time.parse(result[0]['ts_created'])
        }
        attributes
      end

  end
end
