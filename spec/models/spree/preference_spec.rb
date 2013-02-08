require 'spec_helper'

describe Spree::Preference do
  let(:alpha_tenant) { Spree::Tenant.create!(:shortname => 'alpha', :domain => 'alpha.dev') }
  let(:beta_tenant) { Spree::Tenant.create!(:shortname => 'beta', :domain => 'beta.dev') }

  it 'permits saving the same key for two different tenants' do
    Spree::Preference.create!(:key => 'test', :tenant => alpha_tenant, :value_type => :string, :value => 'alpha test')
    Spree::Preference.create!(:key => 'test', :tenant => beta_tenant, :value_type => :string, :value => 'beta test')

    Spree::Tenant.set_current_tenant(alpha_tenant)
    Spree::Preference.find_by_key('test').value.should == 'alpha test'

    Spree::Tenant.set_current_tenant(beta_tenant)
    Spree::Preference.find_by_key('test').value.should == 'beta test'
  end
end
