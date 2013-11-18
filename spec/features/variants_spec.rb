require 'spec_helper'

describe 'Variants' do
  extend AuthorizationHelpers::Request
  stub_authorization!

  let!(:alpha_tenant) { Spree::Tenant.create!(:shortname => 'alpha', :domain => 'alpha.dev') }

  it 'permits adding a variant to a product on a tenant' do
    visit 'http://alpha.dev/admin'
    click_on 'Products'

    click_on 'Option Types'
    click_on 'New Option Type'
    fill_in 'Name', with: 'color'
    fill_in 'Presentation', with: 'Color'
    click_on 'Create'

    find('tr.option_value.fields td.name input').set('red')
    find('tr.option_value.fields td.presentation input').set('Red')
    click_on 'Update'

    click_on 'Products'
    click_on 'New Product'
    fill_in 'Name', with: 'Paper Airplane'
    fill_in 'Master Price', with: '2.99'
    click_on 'Create'

    select 'color', from: 'Option Types'
    click_on 'Update'

    click_on 'Variants'
    click_on 'New Variant'
  end
end
