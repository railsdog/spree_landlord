require 'spec_helper'

Spree::Landlord.model_names.each do |model_name|

  describe model_name do
    describe '#tenant' do
      it "is defined" do
        model = model_name.new
        model.should respond_to(:tenant)
      end

      # TODO: Need to create an easy way to test each models new record tenant for defaults and via assignments
      it "matches the current tenant" do
        Spree::Tenant.stub(:current_tenant_id).and_return(123)
        item = model_name.new
        item.tenant_id.should eq(Thread.current[:tenant_id])
      end

      context 'with new instances' do
        context 'when the current tenant is explicitly set' do
          let(:tenant) { Spree::Tenant.create!(shortname: 'test', domain: 'test.dev') }

          before do
            Spree::Tenant.set_current_tenant(tenant)
          end

          it "returns the explicitly set current tenant" do
            item = model_name.new
            item.tenant.should == tenant
          end
        end

        context 'when the current tenant is implicitly set' do
          it "returns the master tenant" do
            item = model_name.new
            item.tenant.should == Spree::Tenant.master
          end
        end
      end
    end

    describe '#tenant_id' do
      describe 'during validation' do
        def trigger_validation_on(item)
          begin
            item.valid?
          rescue Exception
            # some validations are throwing exceptions, just ignore them
          end
        end

        it 'defaults to Spree::Tenent.current_tenant_id' do
          Spree::Tenant.stub(:current_tenant_id).and_return(1212)
          item = model_name.new
          trigger_validation_on(item)
          item.tenant_id.should == 1212
        end

        it 'does not overwrite existing value' do
          Spree::Tenant.stub(:current_tenant_id).and_return(1212)
          item = model_name.new
          item.tenant_id = 82
          trigger_validation_on(item)
          item.tenant_id.should == 82
        end
      end
    end

    describe 'default scope' do
      it 'delegates to Spree::Tenant.current_tenant_id' do
        Spree::Tenant.stub(:current_tenant_id).and_return(2112)
        model_name.scoped.to_sql.should =~ /tenant_id = 2112/
      end
    end
  end
end
