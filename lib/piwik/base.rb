require 'rubygems'
require 'cgi'
require 'yaml'
require 'rest_client'
require 'xmlsimple'
require 'ostruct'

module Piwik
  class ApiError < StandardError; end
  class SegmentError < StandardError; end
  class MissingConfiguration < ArgumentError; end
  class UnknownSite < ArgumentError; end
  class UnknownUser < ArgumentError; end
  class UnknownGoal < ArgumentError; end

  class Base
    include Piwik::Typecast
    include Piwik::ApiScope
    @@template  = <<-EOF
# .piwik
#
# Please fill in fields like this:
#
#  piwik_url: http://your.piwik.site
#  auth_token: secret
#
piwik_url:
auth_token:
EOF

    # common constructor, using ostruct for attribute storage
    attr_accessor :attributes
    def initialize params = {}
      @attributes = OpenStruct.new
      params.map do |k,v|
        @attributes.send(:"#{k}=",typecast(v))
      end
    end

    def id_attr
      self.class.id_attr
    end

    def save
      if new?
        resp = collection.add(attributes)
        attributes = resp.attributes
        true
      else
        collection.save(attributes)
      end

    end
    alias :update :save

    def delete
      collection.delete(attributes)
    end
    alias :destroy :delete

    # Returns <tt>true</tt> if the current site does not exists in the Piwik yet.
    def new?
      begin
        if respond_to?(:id)
          id.nil? && created_at.blank?
        else
          created_at.blank?
        end

      rescue Exception => e
        nil
      end
    end

    #id will try and return the value of the Piwik item id if it exists
    def id
      begin
        if self.class == Piwik::Site
          self.idsite
        else
          attributes.send(:"id#{self.class.to_s.gsub('Piwik::','')}")
        end
      rescue Exception => e
        $stderr.puts e
      end
    end

    #created_at will try and return the value of the Piwik item id if it exists
    def created_at
      attributes.send(:ts_created) rescue nil
    end

    # delegate attribute calls to @attributes storage
    def method_missing(method,*args,&block)
      if self.attributes.respond_to?(method)
        self.attributes.send(method,*args,&block)
      else
        super
      end
    end

    def parse_xml xml; self.class.parse_xml xml; end

    # Calls the supplied Piwik API method, with the supplied parameters.
    #
    # Returns a string containing the XML reply from Piwik, or raises a
    # <tt>Piwik::ApiError</tt> exception with the error message returned by Piwik
    # in case it receives an error.
    def call(method, params={})
      self.class.call(method, params, config[:piwik_url], config[:auth_token])
    end

    def config
      @config ||= self.class.load_config_from_file
    end

    def collection
      self.class.collection
    end

    class << self
      def collection
        "#{self.to_s.pluralize}".safe_constantize
      end

      # This is required to normalize the API responses when the Rails XmlSimple version is used
      def parse_xml xml
        result = XmlSimple.xml_in(xml, {'ForceArray' => false})
        result = result['result'] if result['result']
        result
      end

      def load id
        collection.get(id_attr => id)
      end
      alias :reload :load

      # Calls the supplied Piwik API method, with the supplied parameters.
      #
      # Returns a string containing the XML reply from Piwik, or raises a
      # <tt>Piwik::ApiError</tt> exception with the error message returned by Piwik
      # in case it receives an error.
      def call(method, params, piwik_url=nil, auth_token=nil)
        params ||= {}
        raise MissingConfiguration, "Please edit ~/.piwik to include your piwik url and auth_key" if piwik_url.nil? || auth_token.nil?
        url = "#{piwik_url}/index.php?"
        params.merge!({:module => 'API', :format => 'xml', :method => method})
        params.merge!({:token_auth => auth_token}) unless auth_token.nil?
        url << params.to_query
        verbose_obj_save = $VERBOSE
        $VERBOSE = nil # Suppress "warning: peer certificate won't be verified in this SSL session"
        xml = RestClient.get(url)
        $VERBOSE = verbose_obj_save
        if xml.is_a?(String) && xml.force_encoding('BINARY').is_binary_data?
          xml.force_encoding('BINARY')
        elsif xml =~ /error message="These reports have no data, because the Segment you requested (direct) has not yet been processed by the system/
          raise SegmentError, "Data temporarily unavailable for given timeframe"
        elsif xml =~ /error message=/
          result = XmlSimple.xml_in(xml, {'ForceArray' => false})
          raise ApiError, result['error']['message'] if result['error']
        else
          xml
        end
      end

      # Checks for the config, creates it if not found
      def load_config_from_file
        # Useful for testing or embedding credentials - although as always
        # it is not recommended to embed any kind of credentials in source code for security reasons
        return { :piwik_url => PIWIK_URL, :auth_token => PIWIK_TOKEN } if PIWIK_URL.present? and PIWIK_TOKEN.present?
        config = {}
        if defined?(RAILS_ROOT) and RAILS_ROOT != nil
          home =  RAILS_ROOT
          filename = "config/piwik.yml"
        else
          home =  ENV['HOME'] || ENV['USERPROFILE'] || ENV['HOMEPATH'] || "."
          filename = ".piwik"
        end
        temp_config = if File.exists?(File.join(home,filename))
          YAML::load(open(File.join(home,filename)))
        else
          open(File.join(home,filename),'w') { |f| f.puts @@template }
          YAML::load(@@template)
        end
        temp_config.each { |k,v| config[k.to_sym] = v } if temp_config
        if config[:piwik_url] == nil || config[:auth_token] == nil
          if defined?(RAILS_ROOT) and RAILS_ROOT != nil
            raise MissingConfiguration, "Please edit ./config/piwik.yml to include your piwik url and auth_key"
          else
            raise MissingConfiguration, "Please edit ~/.piwik to include your piwik url and auth_key"
          end

        end
        config
      end
    end
  end
end

