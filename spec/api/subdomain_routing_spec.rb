require 'spec_helper'

describe 'subdomain routing' do
  let!(:master_tenant) { Spree::Tenant.master }
  let!(:apples_tenant) { Spree::Tenant.create!(:shortname => 'apples', :domain => 'apples.dev') }
  let!(:oranges_tenant) { Spree::Tenant.create!(:shortname => 'oranges', :domain => 'oranges.dev') }
  let!(:mixed_tenant) { Spree::Tenant.create!(:shortname => 'Mixed', :domain => 'mixed.dev') }

  let!(:apple) {
    Spree::Tenant.set_current_tenant(apples_tenant)
    Spree::Product.create!(
      :name => 'Apple',
      :price => 1.99,
      :available_on => 1.day.ago)
  }

  let!(:orange) {
    Spree::Tenant.set_current_tenant(oranges_tenant)
    Spree::Product.create!(
      :name => 'Orange',
      :price => 1.99,
      :available_on => 1.day.ago)
  }

  let!(:fruit_basket) {
    Spree::Tenant.set_current_tenant(mixed_tenant)
    Spree::Product.create!(
      :name => 'Fruit Basket',
      :price => 12.22,
      :available_on => 1.day.ago)
  }

  it 'throws an exception for nonexistent tenants' do
    expect {
      get 'http://blueberries.sample.com/'
    }.to raise_error(Spree::SpreeLandlord::TenantNotFound, "No tenant could be found for 'blueberries.sample.com'")
  end

  it 'correctly selects the master tenant when sub-domain is missing' do
    get "http://#{master_tenant.domain}"
    response.body.should_not include(apple.name)
    response.body.should_not include(orange.name)
  end

  it 'correctly selects the apples tenant' do
    get 'http://apples.sample.com'
    response.body.should include(apple.name)
    response.body.should_not include(orange.name)
  end

  it 'correctly selects the oranges tenant' do
    get 'http://oranges.sample.com'
    response.body.should include(orange.name)
    response.body.should_not include(apple.name)
  end

  describe 'case insensitivity' do
    it 'selects the correct tenant if the domain contains uppercase' do
      get 'http://Oranges.sample.com'
      response.body.should include(orange.name)
      response.body.should_not include(apple.name)
    end

    it 'selects the correct tenant if created with uppercase' do
      get 'http://mixed.sample.com'
      response.body.should include(fruit_basket.name)
      response.body.should_not include(orange.name)
      response.body.should_not include(apple.name)
    end
  end
end
