require 'spec_helper'
require 'ostruct'

describe Spree::SpreeLandlord::TenantFinder do
  describe '#find_target_tenant' do
    subject(:finder) { Spree::SpreeLandlord::TenantFinder.new }
    before { Spree::Tenant.destroy_all }
    let!(:master) { Spree::Tenant.create!(:shortname => 'master', :domain => 'master.com') }
    let!(:apples) { Spree::Tenant.create!(:shortname => 'apples', :domain => 'apples.com') }
    let!(:oranges) { Spree::Tenant.create!(:shortname => 'oranges', :domain => 'oranges.com') }

    def request(uri)
      env = Rack::MockRequest.env_for(uri)
      ActionDispatch::Request.new(env)
    end

    describe 'test setup' do
      it 'has master set correctly' do
        Spree::Tenant.master.should == master
      end
    end

    describe 'subdomain matching' do
      it 'finds correct tenant' do
        finder.find_target_tenant(request('http://apples.sample.com')).should == apples
      end
    end

    describe 'primary domain matching' do
      it 'permits use of unknown subdomains' do
        finder.find_target_tenant(request('http://www.apples.com')).should == apples
      end

      it 'ignores known subdomains' do
        finder.find_target_tenant(request('http://oranges.apples.com')).should == apples
      end
    end

    describe 'subdomains on master domain' do
      it 'permits use of unknown subdomains' do
        finder.find_target_tenant(request('http://www.master.com')).should == master
      end

      it 'honors known subdomain' do
        finder.find_target_tenant(request('http://apples.master.com')).should == apples
      end
    end

    describe 'ip addresses' do
      it 'finds master tenant' do
        finder.find_target_tenant(request('http://127.0.0.1')).should == master
      end
    end

    describe 'localhost' do
      it 'finds master tenant' do
        finder.find_target_tenant(request('http://localhost')).should == master
      end
    end

    it 'raises exception if no matching tenant is found' do
      expect {
        finder.find_target_tenant(request('http://www.sample.com'))
      }.to raise_error(Spree::SpreeLandlord::TenantNotFound, "No tenant could be found for 'www.sample.com'")
    end
  end
end
