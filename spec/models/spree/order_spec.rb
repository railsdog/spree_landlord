require 'spec_helper'

describe Spree::Order do
  let(:order) { Factory(:order) }
  let(:bill_address) { Factory(:address) }

  before do
    order.stub(:bill_address).and_return(bill_address)
    bill_address.tenant_id = 1234
  end

  it "clones a billing address into an empty ship address" do
    order.clone_billing_address
    order.ship_address.tenant_id.should eq(bill_address.tenant_id)
  end

  it "clones a billing address into a non-empty ship address" do
    order.ship_address = Factory(:address)
    order.clone_billing_address
    order.ship_address.tenant_id.should eq(bill_address.tenant_id)
  end
  
end
