module Udger
  class UaParser < BaseParser
    attr_accessor :db, :ua_string, :object

    def initialize(db, ua_string, crawler: true, client: true, os: true, device: true, device_market: true)
      super(db)

      @match_crawler = crawler
      @match_client = client
      @match_os = os
      @match_device = device
      @match_device_market = device_market

      @ua_string = ua_string
      @object = UserAgent.new
      @os_id = 0
      @client_id = 0
      @client_class_id = -1
      @deviceclass_id = 0
    end

    def parse
      return unless ua_string
      object.ua_string = ua_string
      crawler_data = @match_crawler ? parse_crawler : []
      if !crawler_data.empty?
        format_crawler_data crawler_data[0]
      else
        parse_client if @match_client
        if @match_os || @match_device_market
          parse_os
          parse_client_os
        end
        parse_device if @match_device
        devise_market_name if @match_device_market
      end
    end


    private

    def parse_crawler
      query = "SELECT udger_crawler_list.id as botid,name,ver,ver_major,last_seen,respect_robotstxt,family,family_code,family_homepage,family_icon,vendor,vendor_code,vendor_homepage,crawler_classification,crawler_classification_code
               FROM udger_crawler_list
               LEFT JOIN udger_crawler_class ON udger_crawler_class.id=udger_crawler_list.class_id
               WHERE ua_string=?"
      db.execute(query, ua_string)
    end

    def format_crawler_data(result)
      @client_class_id = 99
      @object.ua_class = 'Crawler'
      @object.ua_class_code = 'crawler'
      @object.ua = result['name']
      @object.ua_version = result['ver']
      @object.ua_version_major = result['ver_major']
      @object.ua_family = result['family']
      @object.ua_family_code = result['family_code']
      @object.ua_family_homepage = result['family_homepage']
      @object.ua_family_vendor = result['vendor']
      @object.ua_family_vendor_code = result['vendor_code']
      @object.ua_family_vendor_homepage = result['vendor_homepage']
      @object.ua_family_icon = result['family_icon']
      @object.ua_family_info_url = "https://udger.com/resources/ua-list/bot-detail?bot=#{result['family']}#id#{result['botid']}"
      @object.crawler_last_seen = result['last_seen']
      @object.crawler_category = result['crawler_classification']
      @object.crawler_category_code = result['crawler_classification_code']
      @object.crawler_respect_robotstxt = result['respect_robotstxt']
    end

    def parse_client
      query = "SELECT class_id,client_id,regstring,name,name_code,homepage,icon,icon_big,engine,vendor,vendor_code,vendor_homepage,uptodate_current_version,client_classification,client_classification_code
               FROM udger_client_regex
               JOIN udger_client_list ON udger_client_list.id=udger_client_regex.client_id
               JOIN udger_client_class ON udger_client_class.id=udger_client_list.class_id
               ORDER BY sequence ASC"

      regexp_parse(query) do |match, result|
        @client_id = result['client_id']
        @client_class_id = result['class_id']

        object.ua_class = result['client_classification']
        object.ua_class_code = result['client_classification_code']
        if match[0].is_a? Array
          string = match[0][0]
          object.ua = "#{result['name']} #{string}"
          object.ua_version = string
          object.ua_version_major = string.split('.')[0]
        else
          object.ua = result['name']
        end
        object.ua_uptodate_current_version = result['uptodate_current_version']
        object.ua_family = result['name']
        object.ua_family_code = result['name_code']
        object.ua_family_homepage = result['homepage']
        object.ua_family_vendor = result['vendor']
        object.ua_family_vendor_code = result['vendor_code']
        object.ua_family_vendor_homepage = result['vendor_homepage']
        object.ua_family_icon = result['icon']
        object.ua_family_icon_big = result['icon_big']
        object.ua_family_info_url = 'https://udger.com/resources/ua-list/browser-detail?browser=' + result['name']
        object.ua_engine = result['engine']
      end
    end

    def parse_os
      query = "SELECT os_id,regstring,family,family_code,name,name_code,homepage,icon,icon_big,vendor,vendor_code,vendor_homepage
               FROM udger_os_regex
               JOIN udger_os_list ON udger_os_list.id=udger_os_regex.os_id
               ORDER BY sequence ASC"

      regexp_parse(query) do |_match, result|
        @os_id = result['os_id']
        object.os = result['name']
        object.os_code = result['name_code']
        object.os_homepage = result['homepage']
        object.os_icon = result['icon']
        object.os_icon_big = result['icon_big']
        object.os_info_url = 'https://udger.com/resources/ua-list/os-detail?os=' + result['name']
        object.os_family = result['family']
        object.os_family_code = result['family_code']
        object.os_family_vendor = result['vendor']
        object.os_family_vendor_code = result['vendor_code']
        object.os_family_vendor_homepage = result['vendor_homepage']
      end
    end

    def parse_client_os
      return if !@os_id.zero? || @client_id.zero?

      query = 'SELECT os_id,family,family_code,name,name_code,homepage,icon,icon_big,vendor,vendor_code,vendor_homepage
               FROM udger_client_os_relation
               JOIN udger_os_list ON udger_os_list.id=udger_client_os_relation.os_id
               WHERE client_id=?'

      data = db.execute(query, @client_id)
      return if data.empty?
      result = data[0]
      @os_id = result['os_id']
      object.os = result['name']
      object.os_code = result['name_code']
      object.os_homepage = result['homepage']
      object.os_icon = result['icon']
      object.os_icon_big = result['icon_big']
      object.os_info_url = "https://udger.com/resources/ua-list/os-detail?os=#{result['name']}"
      object.os_family = result['family']
      object.os_family_code = result['family_code']
      object.os_family_vendor = result['vendor']
      object.os_family_vendor_code = result['vendor_code']
      object.os_family_vendor_homepage = result['vendor_homepage']
    end

    def parse_device

      query = 'SELECT deviceclass_id,regstring,name,name_code,icon,icon_big
               FROM udger_deviceclass_regex
               JOIN udger_deviceclass_list ON udger_deviceclass_list.id=udger_deviceclass_regex.deviceclass_id
               ORDER BY sequence ASC'

      regexp_parse(query) do |_match, result|
        @deviceclass_id = result['deviceclass_id']
        object.device_class = result['name']
        object.device_class_code = result['name_code']
        object.device_class_icon = result['icon']
        object.device_class_icon_big = result['icon_big']
        object.device_class_info_url = "https://udger.com/resources/ua-list/device-detail?device=#{result['name']}"
      end

      # If there is no @client_class_id and @match_client is not enabled
      if @client_class_id == -1 && !@match_client
        parse_client
      end

      if @deviceclass_id.zero? && @client_class_id != -1
          query = 'SELECT deviceclass_id,name,name_code,icon,icon_big
                   FROM udger_deviceclass_list
                   JOIN udger_client_class ON udger_client_class.deviceclass_id=udger_deviceclass_list.id
                   WHERE udger_client_class.id=?'
          data = db.execute(query, @client_class_id)
          unless data.empty?
            result = data[0]
            @deviceclass_id = result['deviceclass_id']
            object.device_class = result['name']
            object.device_class_code = result['name_code']
            object.device_class_icon = result['icon']
            object.device_class_icon_big = result['icon_big']
            object.device_class_info_url = "https://udger.com/resources/ua-list/device-detail?device=#{result['name']}"
          end
      end
    end

    def devise_market_name
      return unless object.os_family_code
      # TODO: santize code
      query = "SELECT id,regstring FROM udger_devicename_regex WHERE
               ((os_family_code='" + object.os_family_code + "' AND os_code='-all-')
               OR
               (os_family_code='" + object.os_family_code + "' AND os_code='" + object.os_code + "'))
               ORDER BY sequence"
      regexp_parse(query, false) do |match, result|
        sub_query = "SELECT marketname,brand_code,brand,brand_url,icon,icon_big
                     FROM udger_devicename_list
                     JOIN udger_devicename_brand ON udger_devicename_brand.id=udger_devicename_list.brand_id
                     WHERE regex_id=? and code = ? COLLATE NOCASE"
        qc = db.execute(sub_query, result['id'], match[0])
        unless qc.empty?
          res = qc[0]
          object.device_marketname       = res['marketname']
          object.device_brand            = res['brand']
          object.device_brand_code       = res['brand_code']
          object.device_brand_homepage   = res['brand_url']
          object.device_brand_icon       = res['icon']
          object.device_brand_icon_big   = res['icon_big']
          object.device_brand_info_url   = 'https://udger.com/resources/ua-list/devices-brand-detail?brand=' + res['brand_code']
          break
        end
      end
    end

  end
end
