require 'spec_helper'

describe 'Tenant checkout process' do
  let!(:alpha_tenant) { Spree::Tenant.create!(shortname: 'alpha', domain: 'alpha.dev') }
  let!(:beta_tenant) { Spree::Tenant.create!(shortname: 'beta', domain: 'beta.dev') }

  let!(:alpha_product) {
    Spree::Tenant.set_current_tenant(alpha_tenant)
    Spree::Product.create!(name: 'Alpha Product', price: 9.99, available_on: 1.day.ago)
  }

  let!(:beta_product) {
    Spree::Tenant.set_current_tenant(beta_tenant)
    Spree::Product.create!(name: 'Beta Product', price: 12.25, available_on: 1.day.ago)
  }

  let!(:alpha_shipping) {
    Spree::Tenant.set_current_tenant(alpha_tenant)
    Spree::ShippingMethod.create!(
      name: 'Free Shipping',
      zone: Spree::Zone.where(name: 'North America').first,
      calculator_type: 'Spree::Calculator::FlatRate'
    ).tap do |s|
      s.calculator = Spree::Calculator::FlatRate.create!({calculable: s}, without_protection: true)
      s.save!
    end
  }

  let!(:beta_shipping) {
    Spree::Tenant.set_current_tenant(beta_tenant)
    Spree::ShippingMethod.create!(
      name: 'Free Shipping',
      zone: Spree::Zone.where(name: 'North America').first,
      calculator_type: 'Spree::Calculator::FlatRate'
    ).tap do |s|
      s.calculator = Spree::Calculator::FlatRate.create!({calculable: s}, without_protection: true)
      s.save!
    end
  }

  let!(:alpha_payment_method) {
    Spree::Tenant.set_current_tenant(alpha_tenant)
    Spree::PaymentMethod::Check.create!(
      name: 'Default',
      environment: 'test',
      active: true)
  }

  let!(:beta_payment_method) {
    Spree::Tenant.set_current_tenant(beta_tenant)
    Spree::PaymentMethod::Check.create!(
      name: 'Default',
      environment: 'test',
      active: true)
  }

  it 'purchases a product from the alpha tenant' do
    visit 'http://alpha.dev'
    click_on 'Alpha Product'
    click_on 'Add To Cart'
    click_on 'Checkout'
    fill_in 'Customer E-Mail', with: 'naruto@uzamaki.jp'
    fill_in 'First Name', with: 'Naruto'
    fill_in 'Last Name', with: 'Uzamaki'
    fill_in 'Street Address', with: '126 Ramen Way'
    fill_in 'City', with: 'Konohama'
    fill_in 'order_bill_address_attributes_state_name', with: 'Virginia'
    select 'United States', from: 'Country'
    fill_in 'Zip', with: '23229'
    fill_in 'Phone', with: '8885551212'
    check 'Use Billing Address'
    click_on 'Save and Continue'
    click_on 'Save and Continue'
    click_on 'Save and Continue'
    expect(page).to have_content('Your order has been processed successfully')
  end

  it 'purchases a product from the beta tenant' do
    visit 'http://beta.dev'
    click_on 'Beta Product'
    click_on 'Add To Cart'
    click_on 'Checkout'
    fill_in 'Customer E-Mail', with: 'naruto@uzamaki.jp'
    fill_in 'First Name', with: 'Naruto'
    fill_in 'Last Name', with: 'Uzamaki'
    fill_in 'Street Address', with: '126 Ramen Way'
    fill_in 'City', with: 'Konohama'
    fill_in 'order_bill_address_attributes_state_name', with: 'Virginia'
    select 'United States', from: 'Country'
    fill_in 'Zip', with: '23229'
    fill_in 'Phone', with: '8885551212'
    check 'Use Billing Address'
    click_on 'Save and Continue'
    click_on 'Save and Continue'
    click_on 'Save and Continue'
    expect(page).to have_content('Your order has been processed successfully')
  end
end
