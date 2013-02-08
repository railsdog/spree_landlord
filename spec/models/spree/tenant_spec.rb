require 'spec_helper'

describe Spree::Tenant do
  def assert_requires_attribute(attribute_name)
    tenant = Spree::Tenant.new
    tenant.valid?
    tenant.errors.should include(attribute_name)

    tenant.send("#{attribute_name}=", attribute_name.to_s)
    tenant.valid?
    tenant.errors.should_not include(attribute_name)
  end

  describe '#shortname' do
    it 'converts to lower case on validation' do
      tenant = Spree::Tenant.new
      tenant.shortname = 'SHORTNAME'
      tenant.valid?
      tenant.shortname.should == 'shortname'
    end

    it 'is required' do
      assert_requires_attribute(:shortname)
    end
  end

  describe '#name' do
    it 'defaults to humanized version of shortname if missing' do
      tenant = Spree::Tenant.new
      tenant.shortname = 'testname'
      tenant.valid?
      tenant.name.should == 'Testname'
    end

    it 'correctly handles a shortname with a dash' do
      tenant = Spree::Tenant.new
      tenant.shortname = 'test-name'
      tenant.valid?
      tenant.name.should == 'Test Name'
    end
  end

  describe '#domain' do
    it 'is required' do
      assert_requires_attribute(:domain)
    end
  end

  describe '.master' do
    before do
      Spree::Tenant.destroy_all
    end

    context 'when there are no tenants' do
      it 'creates a tenant to be the master' do
        expect {
          Spree::Tenant.master
        }.to change { Spree::Tenant.count }.from(0).to(1)

        Spree::Tenant.master.should_not be_nil
      end
    end

    context 'when there are tenants' do
      it 'treats the first tenant as the master' do
        first_tenant = Spree::Tenant.create!(shortname: 'first', domain: 'first.dev')
        second_tenant = Spree::Tenant.create!(shortname: 'second', domain: 'second.dev')

        Spree::Tenant.master.should == first_tenant
      end
    end
  end

  describe '.current_tenant' do
    it 'delegates to current_tenant_id' do
      id = 18
      tenant = mock('tenant')
      Spree::Tenant.stub(:current_tenant_id).and_return(id)
      Spree::Tenant.should_receive(:find).with(id).and_return(tenant)
      Spree::Tenant.current_tenant.should == tenant
    end
  end

  describe '.current_tenant_id' do
    after do
      Thread.current[:tenant_id] = nil
    end

    it 'returns current tenant id stored in the current thread if it exists' do
      Thread.current[:tenant_id] = 12
      Spree::Tenant.current_tenant_id.should == 12
    end

    context 'when current thread has no tenant id' do
      it 'returns the master tenant id' do
        tenant = Spree::Tenant.create(shortname: 'test', domain: 'test.dev')
        Thread.current[:tenant_id] = nil
        Spree::Tenant.should_receive(:master).and_return(tenant)

        Spree::Tenant.current_tenant_id.should == tenant.id
      end
    end
  end

  describe '.set_current_tenant' do
    after do
      Thread.current[:tenant_id] = nil
    end

    let(:tenant) { Spree::Tenant.create!(shortname: 'test', domain: 'test.dev') }

    context 'with an integer' do
      it 'sets the tenant id stored in the current thread' do
        Spree::Tenant.set_current_tenant(tenant.id)
        Thread.current[:tenant_id].should == tenant.id
      end

      it 'ensures that the id provided belongs to an actual tenant' do
        id = -1
        expect {
          Spree::Tenant.set_current_tenant(id)
        }.to raise_error(Spree::SpreeLandlord::TenantNotFound, "No tenant found with id = #{id}")
      end
    end

    context 'with a tenant instance' do
      it 'sets the tenant id stored in the current thread to the tenant instance id' do
        Spree::Tenant.set_current_tenant(tenant)
        Thread.current[:tenant_id].should == tenant.id
      end
    end

    context 'with nil' do
      it 'set the tenant id to the id of the master tenant' do
        Thread.current[:tenant_id].should == nil

        Spree::Tenant.set_current_tenant(nil)

        Thread.current[:tenant_id].should == Spree::Tenant.master.id
      end
    end

    context 'with something else' do
      it 'raises an exception' do
        expect {
          Spree::Tenant.set_current_tenant(:foo)
        }.to raise_error(ArgumentError, 'invalid tenant object or id')
      end
    end
  end

  context '#create' do
    let(:created_tenant) do
      Spree::Tenant.create!(shortname: 'temp', domain: 'temp.info')
    end

    before do
      Spree::Tenant.set_current_tenant(created_tenant)
    end

    it 'seeds tenant with roles' do
      expect(Spree::Role.count).to be > 0
    end

    it 'seeds tenant with states' do
      expect(Spree::State.count).to be > 0
    end

    it 'seeds tenant with countries' do
      expect(Spree::Country.count).to be > 0
    end

    it 'seeds tenant with zones' do
      expect(Spree::Zone.count).to be > 0
    end

    it 'seeds tenant with zone_members' do
      expect(Spree::ZoneMember.count).to be > 0
    end
  end
end
