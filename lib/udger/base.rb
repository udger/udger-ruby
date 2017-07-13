require 'sqlite3'
require 'lru_redux'
module Udger
  class Base
    DB_FILENAME = 'udgerdb_v3.dat'.freeze
    attr_reader :db

    def initialize(data_dir = nil, lru_cache_size = 10_000)
      @data_dir = data_dir || __dir__
      @regexp_cache = {}
      return if lru_cache_size.zero?
      @lru_cache = LruRedux::Cache.new(lru_cache_size)
      @db = SQLite3::Database.new "#{@data_dir}/#{DB_FILENAME}"
      @db.results_as_hash = true
    end

    def parse_ua(ua_string)
      cache_string = ua_string.hash
      cache = @lru_cache[cache_string]
      return cache if cache
      parser = UaParser.new @db, ua_string
      parser.parse
      @lru_cache[cache_string] = parser.object
      parser.object
    end

    def parse_ip(ip)
      parser = IpParser.new @db, ip
      parser.parse
      parser.object
    end
  end
end
