require 'spec_helper'

describe 'Zones' do
  extend AuthorizationHelpers::Request
  stub_authorization!

  let!(:alpha_tenant) { Spree::Tenant.create!(:shortname => 'alpha', :domain => 'alpha.dev') }
  let!(:beta_tenant) { Spree::Tenant.create!(:shortname => 'beta', :domain => 'beta.dev') }

  it 'permits creating two zones with the same name on different tenants' do
    visit 'http://alpha.dev/admin'
    click_link 'Configuration'
    click_link 'Zones'
    click_link 'New Zone'
    fill_in 'Name', with: 'Test'
    click_button 'Create'
    expect(page).to have_content('Zone "Test" has been successfully created')

    visit 'http://beta.dev/admin'
    click_link 'Configuration'
    click_link 'Zones'
    click_link 'New Zone'
    fill_in 'Name', with: 'Test'
    click_button 'Create'
    expect(page).to have_content('Zone "Test" has been successfully created')
  end
end
