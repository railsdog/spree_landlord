require 'spec_helper'

describe 'preferences' do
  let!(:alpha_tenant) { Spree::Tenant.create!(:shortname => 'alpha', :domain => 'alpha.dev') }
  let!(:beta_tenant) { Spree::Tenant.create!(:shortname => 'beta', :domain => 'beta.dev') }

  let!(:super_admin) {
    Spree::User.create!(email: 'super@example.com', password: 'spree123')
  }

  let(:alpha_admin) {
    Spree::Tenant.set_current_tenant alpha_tenant
    Spree::User.create!(email: 'alpha@example.com', password: 'spree123').tap do |u|
      u.spree_roles << Spree::Role.find_or_create_by_name(:admin)
      u.tenant = alpha_tenant
      u.save!
    end
  }
  let(:beta_admin) {
    Spree::Tenant.set_current_tenant beta_tenant
    Spree::User.create!(email: 'beta@example.com', password: 'spree123').tap do |u|
      u.spree_roles << Spree::Role.find_or_create_by_name(:admin)
      u.tenant = beta_tenant
      u.save!
    end
  }

  it 'preferences that are set through the admin ui respect tenancy' do
    Rails.cache.clear

    visit 'http://alpha.sample.com/admin'

    fill_in 'Email', :with => alpha_admin.email
    fill_in 'Password', :with => alpha_admin.password
    click_button 'Login'

    click_link "Configuration"
    click_link "General Settings"

    find("#site_name").value.should == "Spree Demo Site"

    fill_in "site_name", :with => "Spree Demo Alpha"
    click_button "Update"

    assert_successful_update_message(:general_settings)
    find("#site_name").value.should == "Spree Demo Alpha"

    visit 'http://beta.sample.com/admin'

    fill_in 'Email', :with => beta_admin.email
    fill_in 'Password', :with => beta_admin.password
    click_button 'Login'

    click_link "Configuration"
    click_link "General Settings"

    find("#site_name").value.should == "Spree Demo Site"

    fill_in "site_name", :with => "Spree Demo Beta"
    click_button "Update"

    assert_successful_update_message(:general_settings)
    find("#site_name").value.should == "Spree Demo Beta"

    visit 'http://alpha.sample.com/admin'

    fill_in 'Email', :with => alpha_admin.email
    fill_in 'Password', :with => alpha_admin.password
    click_button 'Login'

    click_link "Configuration"
    click_link "General Settings"

    find("#site_name").value.should == "Spree Demo Alpha"

    visit 'http://beta.sample.com/admin'

    fill_in 'Email', :with => beta_admin.email
    fill_in 'Password', :with => beta_admin.password
    click_button 'Login'

    click_link "Configuration"
    click_link "General Settings"

    find("#site_name").value.should == "Spree Demo Beta"
  end

end
