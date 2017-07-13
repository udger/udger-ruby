require 'spec_helper'

describe 'Parser' do

  before :each do
    @parser = Udger::Base.new('/Users/bojan/igralist/udger/')
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
