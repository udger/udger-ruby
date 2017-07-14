require 'ipaddr'
module Udger
  class IpParser < BaseParser
    attr_accessor :db, :object, :ip

    def initialize(db, ip)
      super(db)
      @ip = ip
      @object = IpAddress.new
    end

    def parse
      return unless @ip
      object.ip = @ip
      parse_ip_object
    end

    def parse_ip_object
      ip_object = fetch_ip()
      return if ip_object.nil?
      object.ip_ver = ip_object.ipv4? ? 4 : 6
      query = "SELECT udger_crawler_list.id as botid,ip_last_seen,ip_hostname,ip_country,ip_city,ip_country_code,ip_classification,ip_classification_code,
                      name,ver,ver_major,last_seen,respect_robotstxt,family,family_code,family_homepage,family_icon,vendor,vendor_code,vendor_homepage,crawler_classification,crawler_classification_code
               FROM udger_ip_list
               JOIN udger_ip_class ON udger_ip_class.id=udger_ip_list.class_id
               LEFT JOIN udger_crawler_list ON udger_crawler_list.id=udger_ip_list.crawler_id
               LEFT JOIN udger_crawler_class ON udger_crawler_class.id=udger_crawler_list.class_id
               WHERE ip=? ORDER BY sequence"
      data = db.execute(query, ip_object.to_s)
      unless data.empty?
        result = data[0]
        object.ip_classification = result['ip_classification']
        object.ip_classification_code = result['ip_classification_code']
        object.ip_last_seen = result['ip_last_seen']
        object.ip_hostname = result['ip_hostname']
        object.ip_country = result['ip_country']
        object.ip_country_code = result['ip_country_code']
        object.ip_city = result['ip_city']
        object.crawler_name = result['name']
        object.crawler_ver = result['ver']
        object.crawler_ver_major = result['ver_major']
        object.crawler_family = result['family']
        object.crawler_family_code = result['family_code']
        object.crawler_family_homepage = result['family_homepage']
        object.crawler_family_vendor = result['vendor']
        object.crawler_family_vendor_code = result['vendor_code']
        object.crawler_family_vendor_homepage = result['vendor_homepage']
        object.crawler_family_icon = result['family_icon']
        if result['ip_classification_code'] == 'crawler'
          object.crawler_family_info_url = "https://udger.com/resources/ua-list/bot-detail?bot=#{result['family']}#id#{result['botid']}"
        end
        object.crawler_last_seen = result['last_seen']
        object.crawler_category = result['crawler_classification']
        object.crawler_category_code = result['crawler_classification_code']
        object.crawler_respect_robotstxt = result['respect_robotstxt']
      else
        object.ip_classification = 'Unrecognized'
        object.ip_classification_code = 'Unrecognized'
      end

      if object.ip_ver == 4
        ip4_format(ip_object)
      else
        ip6_format(ip_object)
      end
    end

    def ip4_format(ip_object)
      query = 'SELECT name,name_code,homepage
               FROM udger_datacenter_range
               JOIN udger_datacenter_list ON udger_datacenter_range.datacenter_id=udger_datacenter_list.id
               WHERE iplong_from <= ? AND iplong_to >= ?'
      ip_int = ip_object.to_i
      data = db.execute(query, ip_int, ip_int)
      return if data.empty?
      result = data[0]
      object.datacenter_name = result['name']
      object.datacenter_name_code = result['name_code']
      object.datacenter_homepage = result['homepage']
    end

    def ip6_format(ip_object)
      ip_range = ip_object.to_string.split(':').map { |x| x.to_i(16) }
      query = 'SELECT name,name_code,homepage
               FROM udger_datacenter_range6
               JOIN udger_datacenter_list ON udger_datacenter_range6.datacenter_id=udger_datacenter_list.id
               WHERE '
      ip_range.each_with_index do |value, index|
        query += " iplong_from#{index} <= #{value} AND iplong_to#{index} >= #{value}"
        query += ' AND ' if index < 7
      end

      data = db.execute(query)
      return if data.empty?
      result = data[0]
      object.datacenter_name = result['name']
      object.datacenter_name_code = result['name_code']
      object.datacenter_homepage = result['homepage']
    end

    def fetch_ip
      IPAddr.new @ip
    rescue
      nil
    end
  end
end
