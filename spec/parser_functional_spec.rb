require 'spec_helper'

describe 'Parser' do

  it 'no db' do
    expect{ parser = Udger::Parser.new('/Users/bojan/igralis') }.to raise_error(SQLite3::CantOpenException)
  end

  it 'db' do
    expect{ parser = Udger::Parser.new('/Users/bojan/igralist/udger/') }.to_not raise_error(SQLite3::CantOpenException)
    expect{ parser = Udger::Parser.new('../../igralist/udger/') }.to_not raise_error(SQLite3::CantOpenException)
  end

  describe 'caching' do
    it 'cache enabled' do
      parser = Udger::Parser.new('/Users/bojan/igralist/udger/')

      result = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      result2 = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      expect(result.to_h).to eq(result2.to_h)
    end

    it 'cache disabled' do
      parser = Udger::Parser.new('/Users/bojan/igralist/udger/', cache: false)

      result = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      result2 = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      expect(result.to_h).to eq(result2.to_h)
    end
  end

  describe 'match type' do
    it 'client' do
      parser = Udger::Parser.new('/Users/bojan/igralist/udger/', ua_services: [:client])
      result = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'

      expect(result.ua_string).to eql 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      expect(result.ua_class).to eql 'Browser'
      expect(result.ua_class_code).to eql 'browser'
      expect(result.ua).to eql 'Firefox 40.0'
      expect(result.ua_version).to eql '40.0'
      expect(result.ua_version_major).to eql '40'
      expect(result.ua_uptodate_current_version).to eql '54'
      expect(result.ua_family).to eql 'Firefox'
      expect(result.ua_family_code).to eql 'firefox'
      expect(result.ua_family_homepage).to eql 'http://www.firefox.com/'
      expect(result.ua_family_vendor).to eql 'Mozilla Foundation'
      expect(result.ua_family_vendor_code).to eql 'mozilla_foundation'
      expect(result.ua_family_vendor_homepage).to eql 'http://www.mozilla.org/'
      expect(result.ua_family_icon).to eql 'firefox.png'
      expect(result.ua_family_icon_big).to eql 'firefox_big.png'
      expect(result.ua_family_info_url).to eql 'https://udger.com/resources/ua-list/browser-detail?browser=Firefox'
      expect(result.ua_engine).to eql 'Gecko'
      expect(result.os).to eql nil
      expect(result.os_code).to eql nil
      expect(result.os_homepage).to eql nil
      expect(result.os_icon).to eql nil
      expect(result.os_icon_big).to eql nil
      expect(result.os_info_url).to eql nil
      expect(result.os_family).to eql nil
      expect(result.os_family_code).to eql nil
      expect(result.os_family_vendor).to eql nil
      expect(result.os_family_vendor_code).to eql nil
      expect(result.os_family_vendor_homepage).to eql nil
      expect(result.device_class).to eql nil
      expect(result.device_class_code).to eql nil
      expect(result.device_class_icon).to eql nil
      expect(result.device_class_icon_big).to eql nil
      expect(result.device_class_info_url).to eql nil
      expect(result.device_marketname).to eql nil
      expect(result.device_brand).to eql nil
      expect(result.device_brand_code).to eql nil
      expect(result.device_brand_homepage).to eql nil
      expect(result.device_brand_icon).to eql nil
      expect(result.device_brand_icon_big).to eql nil
      expect(result.device_brand_info_url).to eql nil
      expect(result.crawler_category).to eql nil
      expect(result.crawler_category_code).to eql nil
      expect(result.crawler_respect_robotstxt).to eql nil

    end

    it 'os'  do

      parser = Udger::Parser.new('/Users/bojan/igralist/udger/', ua_services: [:os])
      result = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'

      expect(result.ua_string).to eql 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      expect(result.ua_class).to eql nil
      expect(result.ua_class_code).to eql nil
      expect(result.ua).to eql nil
      expect(result.ua_version).to eql nil
      expect(result.ua_version_major).to eql nil
      expect(result.ua_uptodate_current_version).to eql nil
      expect(result.ua_family).to eql nil
      expect(result.ua_family_code).to eql nil
      expect(result.ua_family_homepage).to eql nil
      expect(result.ua_family_vendor).to eql nil
      expect(result.ua_family_vendor_code).to eql nil
      expect(result.ua_family_vendor_homepage).to eql nil
      expect(result.ua_family_icon).to eql nil
      expect(result.ua_family_icon_big).to eql nil
      expect(result.ua_family_info_url).to eql nil
      expect(result.ua_engine).to eql nil
      expect(result.os).to eql 'Windows 10'
      expect(result.os_code).to eql 'windows_10'
      expect(result.os_homepage).to eql 'https://en.wikipedia.org/wiki/Windows_10'
      expect(result.os_icon).to eql 'windows10.png'
      expect(result.os_icon_big).to eql 'windows10_big.png'
      expect(result.os_info_url).to eql 'https://udger.com/resources/ua-list/os-detail?os=Windows 10'
      expect(result.os_family).to eql 'Windows'
      expect(result.os_family_code).to eql 'windows'
      expect(result.os_family_vendor).to eql 'Microsoft Corporation.'
      expect(result.os_family_vendor_code).to eql 'microsoft_corporation'
      expect(result.os_family_vendor_homepage).to eql 'https://www.microsoft.com/about/'
      expect(result.device_class).to eql nil
      expect(result.device_class_code).to eql nil
      expect(result.device_class_icon).to eql nil
      expect(result.device_class_icon_big).to eql nil
      expect(result.device_class_info_url).to eql nil
      expect(result.device_marketname).to eql nil
      expect(result.device_brand).to eql nil
      expect(result.device_brand_code).to eql nil
      expect(result.device_brand_homepage).to eql nil
      expect(result.device_brand_icon).to eql nil
      expect(result.device_brand_icon_big).to eql nil
      expect(result.device_brand_info_url).to eql nil
      expect(result.crawler_category).to eql nil
      expect(result.crawler_category_code).to eql nil
      expect(result.crawler_respect_robotstxt).to eql nil

    end

    it 'device ' do
      parser = Udger::Parser.new('/Users/bojan/igralist/udger/', ua_services: [:device])
      result = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      expect(result.ua_string).to eql 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      expect(result.ua_class).to eql 'Browser'
      expect(result.ua_class_code).to eql 'browser'
      expect(result.ua).to eql 'Firefox 40.0'
      expect(result.ua_version).to eql '40.0'
      expect(result.ua_version_major).to eql '40'
      expect(result.ua_uptodate_current_version).to eql '54'
      expect(result.ua_family).to eql 'Firefox'
      expect(result.ua_family_code).to eql 'firefox'
      expect(result.ua_family_homepage).to eql 'http://www.firefox.com/'
      expect(result.ua_family_vendor).to eql 'Mozilla Foundation'
      expect(result.ua_family_vendor_code).to eql 'mozilla_foundation'
      expect(result.ua_family_vendor_homepage).to eql 'http://www.mozilla.org/'
      expect(result.ua_family_icon).to eql 'firefox.png'
      expect(result.ua_family_icon_big).to eql 'firefox_big.png'
      expect(result.ua_family_info_url).to eql 'https://udger.com/resources/ua-list/browser-detail?browser=Firefox'
      expect(result.ua_engine).to eql 'Gecko'
      expect(result.os).to eql nil
      expect(result.os_code).to eql nil
      expect(result.os_homepage).to eql nil
      expect(result.os_icon).to eql nil
      expect(result.os_icon_big).to eql nil
      expect(result.os_info_url).to eql nil
      expect(result.os_family).to eql nil
      expect(result.os_family_code).to eql nil
      expect(result.os_family_vendor).to eql nil
      expect(result.os_family_vendor_code).to eql nil
      expect(result.os_family_vendor_homepage).to eql nil
      expect(result.device_class).to eql 'Desktop'
      expect(result.device_class_code).to eql 'desktop'
      expect(result.device_class_icon).to eql 'desktop.png'
      expect(result.device_class_icon_big).to eql 'desktop_big.png'
      expect(result.device_class_info_url).to eql 'https://udger.com/resources/ua-list/device-detail?device=Desktop'
      expect(result.device_marketname).to eql nil
      expect(result.device_brand).to eql nil
      expect(result.device_brand_code).to eql nil
      expect(result.device_brand_homepage).to eql nil
      expect(result.device_brand_icon).to eql nil
      expect(result.device_brand_icon_big).to eql nil
      expect(result.device_brand_info_url).to eql nil
      expect(result.crawler_category).to eql nil
      expect(result.crawler_category_code).to eql nil
      expect(result.crawler_respect_robotstxt).to eql nil

    end
    it 'client, os,  device, device_market ' do

      parser = Udger::Parser.new('/Users/bojan/igralist/udger/', ua_services: [:client, :os, :device, :device_market])

      result = parser.parse_ua 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'

      expect(result.ua_string).to eql 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
      expect(result.ua_class).to eql 'Browser'
      expect(result.ua_class_code).to eql 'browser'
      expect(result.ua).to eql 'Firefox 40.0'
      expect(result.ua_version).to eql '40.0'
      expect(result.ua_version_major).to eql '40'
      expect(result.ua_uptodate_current_version).to eql '54'
      expect(result.ua_family).to eql 'Firefox'
      expect(result.ua_family_code).to eql 'firefox'
      expect(result.ua_family_homepage).to eql 'http://www.firefox.com/'
      expect(result.ua_family_vendor).to eql 'Mozilla Foundation'
      expect(result.ua_family_vendor_code).to eql 'mozilla_foundation'
      expect(result.ua_family_vendor_homepage).to eql 'http://www.mozilla.org/'
      expect(result.ua_family_icon).to eql 'firefox.png'
      expect(result.ua_family_icon_big).to eql 'firefox_big.png'
      expect(result.ua_family_info_url).to eql 'https://udger.com/resources/ua-list/browser-detail?browser=Firefox'
      expect(result.ua_engine).to eql 'Gecko'
      expect(result.os).to eql 'Windows 10'
      expect(result.os_code).to eql 'windows_10'
      expect(result.os_homepage).to eql 'https://en.wikipedia.org/wiki/Windows_10'
      expect(result.os_icon).to eql 'windows10.png'
      expect(result.os_icon_big).to eql 'windows10_big.png'
      expect(result.os_info_url).to eql 'https://udger.com/resources/ua-list/os-detail?os=Windows 10'
      expect(result.os_family).to eql 'Windows'
      expect(result.os_family_code).to eql 'windows'
      expect(result.os_family_vendor).to eql 'Microsoft Corporation.'
      expect(result.os_family_vendor_code).to eql 'microsoft_corporation'
      expect(result.os_family_vendor_homepage).to eql 'https://www.microsoft.com/about/'
      expect(result.device_class).to eql 'Desktop'
      expect(result.device_class_code).to eql 'desktop'
      expect(result.device_class_icon).to eql 'desktop.png'
      expect(result.device_class_icon_big).to eql 'desktop_big.png'
      expect(result.device_class_info_url).to eql 'https://udger.com/resources/ua-list/device-detail?device=Desktop'
      expect(result.device_marketname).to eql nil
      expect(result.device_brand).to eql nil
      expect(result.device_brand_code).to eql nil
      expect(result.device_brand_homepage).to eql nil
      expect(result.device_brand_icon).to eql nil
      expect(result.device_brand_icon_big).to eql nil
      expect(result.device_brand_info_url).to eql nil
      expect(result.crawler_category).to eql nil
      expect(result.crawler_category_code).to eql nil
      expect(result.crawler_respect_robotstxt).to eql nil

    end
  end
  before :each do
    @parser = Udger::Parser.new('/Users/bojan/igralist/udger/')
  end

  describe 'ip' do
    ip_file = File.open('spec/fixtures/ip.json', 'r')
    ips = JSON.parse(ip_file.read)
    ips.each do |ua|
      it ua['test']['teststring'] do
        res = @parser.parse_ip(ua['test']['teststring'])
        res_hash = res.to_h
        ua['ret'].each do |key, value|
          expect(res_hash[key.to_sym]).to eq(value)
        end
      end
    end
  end

  describe 'user agent' do

    user_agent_file = File.open('spec/fixtures/user_agent.json', 'r')
    user_agents = JSON.parse(user_agent_file.read)
    user_agents.each do |ua|
      it ua['test']['teststring'] do 
        res = @parser.parse_ua(ua['test']['teststring'])
        res_hash = res.to_h
        ua['ret'].each do |key, value|
          expect(res_hash[key.to_sym]).to eq(value)
        end
      end
    end
  end
end
