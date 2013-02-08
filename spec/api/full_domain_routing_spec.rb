require 'spec_helper'

describe 'full domain routing' do
  let!(:apples_tenant) { Spree::Tenant.create!(:shortname => 'apples', :domain => 'apples.com', :name => 'Apple') }
  let!(:oranges_tenant) { Spree::Tenant.create!(:shortname => 'oranges', :domain => 'oranges.com', :name => 'Orange') }

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

  it 'correctly selects the apples tenant' do
    get 'http://apples.com'
    response.body.should include(apple.name)
    response.body.should_not include(orange.name)
  end

  it 'correctly selects the oranges tenant' do
    get 'http://oranges.com'
    response.body.should include(orange.name)
    response.body.should_not include(apple.name)
  end

  it 'ignores subdomains at apples.com' do
    get 'http://oranges.apples.com'
    response.body.should include(apple.name)
    response.body.should_not include(orange.name)
  end

  it 'ignores subdomains at oranges.com' do
    get 'http://apples.oranges.com'
    response.body.should include(orange.name)
    response.body.should_not include(apple.name)
  end
end
