# Autometal-Piwik [![Build Status](https://travis-ci.org/piwik/piwik-ruby-api.png?branch=master)](https://travis-ci.org/piwik/piwik-ruby-api) [![Gem Version](https://badge.fury.io/rb/autometal-piwik.png)](http://badge.fury.io/rb/autometal-piwik)

This is now the official Ruby client for Piwik. It completely covers the Piwik API and should be easily extendable by users. We made no assumptions on how you want to use your data, so we closely mirrored Piwik's API structure even if it looks kinda weird to a modern rubyist.

We will also implement an extended `Piwik::Site` wrapper class that will give you ruby-friendly access to a lot of the data in a way we think is sane, but it will be up to you which interface you want to use.

**Please note that this release is not backward compatible. People using an older version of this gem should stick with version 0.6.1**

## Features
  * Simple ruby-friendly api
  * Full API implementation
  * `piwik-terminal` binary, allowing shell access.
  * Works on MRI Jruby and RBX 1.8.* and 1.9.*
  * Tested
  
## Installation

Add this line to your application's Gemfile:

    gem 'autometal-piwik', :require => 'piwik'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install autometal-piwik

## Usage
### Use the binary
Open an extended irb session to a Piwik installation:

    $ piwik-console -u http://demo.piwik.org -t anonymous
    :001 > Site.load 7
    #=> #<Piwik::Site[snip]>

### Initialize it
Unless you are using the binary, or if you are using the binary without credentials, you need to specify a url and a security token.

    Piwik::PIWIK_URL = 'http://demo.piwik.org'
    Piwik::PIWIK_TOKEN = 'anonymous'

This can take place in your script or a rails initializer or whatever.

### Use the wrapper class
Fastest way to get to know the client is by using the Piwik::Site wrapper class:
    
    site = Piwik::Site.load(7)
    #=> #<Piwik::Site[snip]>
    
    site.annotations.all
    #=> #<Piwik::Annotations[snip]>
    site.annotations.add(:date => 'today', :starred => 1)
    #=> Piwik::ApiError: Please specify a value for 'note'.
    site.annotations.add(:note => 'meep', :date => 'today', :starred => 1)
    #=> #<Piwik::Annotations[snip]>
    
    summary = site.actions.summary
    #=> #<Piwik::Actions[snip]>
    summary.nb_pageviews
    #=> 236 
    summary.nb_uniq_pageviews
    #=> 170

Not all methods are implemented on the wrapper class, although if you find yourself adding methods, please submit a pull request.
You can have a look at [site_spec.rb](https://github.com/piwik/piwik-ruby-api/blob/master/spec/site_spec.rb) for an up-to-date list of available methods.

### Use the 'native' API
This client also allows you to interact with the API the way its designers wanted it. Any method in the [api reference](http://piwik.org/docs/analytics-api/reference/) is made available almost verbatim:

    # http://piwik.org/docs/analytics-api/reference/#Actions
    # Actions.getPageUrls (idSite, period, date, segment = '', expanded = '', idSubtable = '')
    require 'rubygems'
    require 'piwik'
    Piwik::PIWIK_URL = 'http://demo.piwik.org'
    Piwik::PIWIK_TOKEN = 'anonymous'
    Piwik::Actions.getPageUrls(:idSite => 7, :period => :day, :date => 'yesterday')
    #=> #<Piwik::Actions::PageUrls @data=[snip]>

That last call is exactly the same as calling `site.actions.page_urls(:period => :day, :date => 'yesterday')`

It is probably apparent, but the second way gives you full access to everything, all you need is the API reference and you're off. If you are simply after displaying the basic analytics values for a site, the wrapper is probably the way to go.

For more information on Piwik and it’s API, see the [Piwik website](http://piwik.org) and the [Piwik API reference](http://piwik.org/docs/analytics-api/reference/).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
