require 'sqlite3'
require 'lru_redux'
module Udger
  class Parser
    DB_FILENAME = 'udgerdb_v3.dat'.freeze
    attr_reader :db
    attr_reader :data_dir
    attr_accessor :cache
    attr_accessor :lru_cache_size

    def initialize(data_dir = nil, lru_cache_size: 10_000, cache: true, ua_services: [])
      @data_dir = data_dir || __dir__
      @db = SQLite3::Database.new "#{@data_dir}/#{DB_FILENAME}"
      @db.results_as_hash = true
      @cache = cache
      parse_ua_params(ua_services)
      @lru_cache = lru_cache_size.zero? && !cache ? {} : LruRedux::Cache.new(lru_cache_size)
    end


    def parse_ua(ua_string)
      if @cache
        cache_string = ua_string.hash
        cache_value = @lru_cache[cache_string]
        return cache_value if cache_value
        result = parse_ua_no_cache(ua_string)
        @lru_cache[cache_string] = result
        result
      else
        parse_ua_no_cache(ua_string)
      end
    end

    def parse_ip(ip)
      parser = IpParser.new @db, ip
      parser.parse
      parser.object
    end

    private

    def parse_ua_params(parse)
      parsers = parse.empty?
      @match_ua = {}
      [:crawler, :client, :os, :device, :device_market].each do |p|
        @match_ua[p] = parsers || parse.include?(p)
      end
    end

    def parse_ua_no_cache(ua_string)
      parser = UaParser.new @db, ua_string, @match_ua
      parser.parse
      parser.object
    end
  end
end
