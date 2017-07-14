# Udger

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/udger`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'udger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install udger

## Usage

User agent and ip parser for Udger db.


    require 'udger'
    parser = Udger::Parser.new('path_to_udger_db', options) # File must be named 'udgerdb_v3.dat'


### Options

  - cache - default is true, enable caching results. Only available for user agent parsing.
  - lru_cache_size - default is 10,000. How many objects to be cached.
  - ua_services - if you do not need all the information for a user agent, you can specify which services to receive. Available services are: [:crawler, :client, :os, :device, :device_market]. Reducing the number of services will improve performances.


### Parsing user agent

    parser.parse_ua('Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0')

This returns a struct with the following data. If data are not present, it will return nil value.

   - ua_class
   - ua_class_code
   - ua
   - ua_version
   - ua_version_major
   - ua_uptodate_current_version
   - ua_family
   - ua_family_code
   - ua_family_homepage
   - ua_family_vendor
   - ua_family_vendor_code
   - ua_family_vendor_homepage
   - ua_family_icon
   - ua_family_icon_big
   - ua_family_info_url
   - ua_engine
   - os
   - os_code
   - os_homepage
   - os_icon
   - os_icon_big
   - os_info_url
   - os_family
   - os_family_code
   - os_family_vendor
   - os_family_vendor_code
   - os_family_vendor_homepage
   - device_class
   - device_class_code
   - device_class_icon
   - device_class_icon_big
   - device_class_info_url
   - device_marketname
   - device_brand
   - device_brand_code
   - device_brand_homepage
   - device_brand_icon
   - device_brand_icon_big
   - device_brand_info_url
   - crawler_last_seen
   - crawler_category
   - crawler_category_code
   - crawler_respect_robotstxt

### Parsing ip

    parser.parse_ip('108.61.199.93')
    parser.parse_ip('2a02:598:111::9')


This returns a struct with the following data. If data are not present, it will return nil value.

  - ip_ver
  - ip_classification
  - ip_classification_code
  - ip_hostname
  - ip_last_seen
  - ip_country
  - ip_country_code
  - ip_city
  - crawler_name
  - crawler_ver
  - crawler_ver_major
  - crawler_family
  - crawler_family_code
  - crawler_family_homepage
  - crawler_family_vendor
  - crawler_family_vendor_code
  - crawler_family_vendor_homepage
  - crawler_family_icon
  - crawler_family_info_url
  - crawler_last_seen
  - crawler_category
  - crawler_category_code
  - crawler_respect_robotstxt
  - datacenter_name
  - datacenter_name_code
  - datacenter_homepage


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TowerData/udger.

