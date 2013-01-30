require 'spec_helper'

describe 'super admin users' do
  let!(:apples_tenant) { FactoryGirl.create(:tenant, :shortname => 'apples', :domain => 'apples.com', name: "Apple") }
  let!(:oranges_tenant) { FactoryGirl.create(:tenant, :shortname => 'oranges', :domain => 'oranges.com', name: "Orange") }

  let!(:super_admin) {
    Spree::User.create!(email: 'super-admin@example.com', password: 'spree123').tap do |u|
      u.tenant = apples_tenant
      u.super_admin = true
      u.spree_roles << Spree::Role.find_by_name(:admin)
      u.save!
    end
  }

  let!(:oranges_admin) {
    Spree::Tenant.set_current_tenant oranges_tenant
    Spree::User.create!(email: 'oranges@example.com', password: 'spree123').tap do |u|
      u.spree_roles << Spree::Role.find_or_create_by_name(:admin)
      u.save!
    end
  }

  before {
    Spree::Tenant.set_current_tenant apples_tenant
    Spree::Role.find_or_create_by_name(:user)
    Spree::Role.find_or_create_by_name(:admin)
  }


  it 'can log into the tenant backend it belongs to' do
    visit 'http://apples.example.com/admin'

    fill_in 'Email', :with => super_admin.email
    fill_in 'Password', :with => super_admin.password
    click_button 'Login'

    page.should_not have_content('Invalid email or password')
    page.should have_content("Logged in as: #{super_admin.email}")
  end

  it 'can log into the tenant backend it does not belong to' do
    visit 'http://oranges.example.com/admin'

    fill_in 'Email', :with => super_admin.email
    fill_in 'Password', :with => super_admin.password
    click_button 'Login'

    page.should_not have_content('Invalid email or password')
    page.should have_content("Logged in as: #{super_admin.email}")
  end

  it 'can create super admin users' do
    visit 'http://apples.example.com/admin/users/new'

    fill_in 'Email', :with => super_admin.email
    fill_in 'Password', :with => super_admin.password
    click_button 'Login'

    fill_in 'Email', :with => 'user@example.com'
    fill_in 'Password', :with => 'spree123'
    fill_in 'Password Confirmation', :with => 'spree123'
    check 'user_super_admin'
    click_button 'Create'

    page.should have_content('Listing Users')
    page.should have_content('user@example.com')

    user = Spree::User.find_by_email('user@example.com')
    user.should have_spree_role(:admin)
    user.should be_super_admin
  end

  it 'can create admin users' do
    visit 'http://apples.example.com/admin/users/new'

    fill_in 'Email', :with => super_admin.email
    fill_in 'Password', :with => super_admin.password
    click_button 'Login'

    fill_in 'Email', :with => 'user@example.com'
    fill_in 'Password', :with => 'spree123'
    fill_in 'Password Confirmation', :with => 'spree123'
    check 'user_spree_role_admin'
    click_button 'Create'

    page.should have_content('Listing Users')
    page.should have_content('user@example.com')

    user = Spree::User.find_by_email('user@example.com')
    user.should have_spree_role(:admin)
    user.should_not be_super_admin
  end

  it 'can create customer users' do
    visit 'http://apples.example.com/admin/users/new'

    fill_in 'Email', :with => super_admin.email
    fill_in 'Password', :with => super_admin.password
    click_button 'Login'

    fill_in 'Email', :with => 'user@example.com'
    fill_in 'Password', :with => 'spree123'
    fill_in 'Password Confirmation', :with => 'spree123'

    check 'user_spree_role_user'
    click_button 'Create'

    page.should have_content('Listing Users')
    page.should have_content('user@example.com')

    user = Spree::User.find_by_email('user@example.com')
    user.should have_spree_role(:user)
    user.should_not have_spree_role(:admin)
    user.should_not be_super_admin
  end

  it 'show up the user lists of all tenant backends' do
    visit 'http://oranges.example.com/admin/users'

    fill_in 'Email', :with => oranges_admin.email
    fill_in 'Password', :with => oranges_admin.password
    click_button 'Login'

    page.should have_link(oranges_admin.email)
    page.should have_link(super_admin.email)
  end
end
