require 'spec_helper'

describe 'preferences' do
  let!(:apples_tenant) { Spree::Tenant.create!(:shortname => 'apples', :domain => 'apples.com') }
  let!(:oranges_tenant) { Spree::Tenant.create!(:shortname => 'oranges', :domain => 'oranges.com') }

  let!(:apples_tenant_site_name) {
    Spree::Tenant.set_current_tenant(apples_tenant)
    Spree::Config[:site_name] = 'The Best Apples Around'
  }

  let!(:oranges_tenant_site_name) {
    Spree::Tenant.set_current_tenant(oranges_tenant)
    Spree::Config[:site_name] = 'Juicy Oranges'
  }

  it 'selects preferences for apples tenant' do
    get 'http://apples.com'
    response.body.should include(apples_tenant_site_name)
  end

  it 'selects preferences for oranges tenant' do
    get 'http://oranges.com'
    response.body.should include(oranges_tenant_site_name)
  end
end
