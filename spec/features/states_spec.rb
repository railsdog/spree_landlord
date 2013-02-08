require 'spec_helper'

describe 'States' do
  extend AuthorizationHelpers::Request
  stub_authorization!

  let!(:alpha_tenant) { Spree::Tenant.create!(:shortname => 'alpha', :domain => 'alpha.dev') }

  it 'can view states without crashing' do
    visit 'http://alpha.dev/admin'
    click_link 'Configuration'
    click_link 'States'
    expect(page).to have_content('Alabama')
  end
end
