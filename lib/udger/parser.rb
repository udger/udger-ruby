module Udger
  class Parser
    attr_accessor :db, :ua_string, :object, :ip

    def initialize(db)
      @db = db
    end

    protected

    def regexp(string)
      r1 = string.index('/')
      r2 = string.length - string.reverse.index('/') - 1
      Regexp.new string[r1 + 1..r2 - 1], true
    end

    def regexp_parse(query, _cache = true)
      db.execute(query) do |row|
        match = ua_string.scan(regexp(row['regstring']))
        unless match.empty?
          yield match, row
          break
        end
      end
    end
  end
end
