# the goal here is to test deface-enabled tenant view paths
require 'spec_helper'

describe Spree::ProductsController do
  render_views # force view creation - http://stackoverflow.com/questions/1063073/rspec-controller-testing-blank-response-body

  let(:compiled_views_dir)                      { 'spec/dummy/app/compiled_views'}
  let(:user) { create(:user) }

  before do
    controller.stub(:spree_current_user => user)

    Spree::Tenant.all.map(&:destroy)
    @orange_tenant = Spree::Tenant.create!(name: 'orange', shortname: 'orange', domain: 'orange.domain')
    @green_tenant =  Spree::Tenant.create!(name: 'green', shortname: 'green', domain: 'green.domain')

    FileUtils.rm_rf(compiled_views_dir)
    Rails.application.config.deface.overrides.all.clear
  end

  # this section is duplicated in spec/deface/overrides_spec - we are actually going thru the controller here
  # so code review where it belongs.  the naming is better here, but i suspect these should've remained in overrides_spec
  context "overrides with a 'tenant_name' key" do
    before do
      Spree::Tenant.set_current_tenant(@orange_tenant) 
      request.stub(:domain => 'orange.domain')          
      # make sure our product gets created w/ the correct tenant id
      @product = create(:product, :available_on => 1.year.ago)
    end

    context "the disabled key" do
      context "is not present" do
        it "should be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                               :virtual_path => "spree/products/show", 
                               :name => "Posts#index", 
                               :insert_after => "div", 
                               :text => "runtime orange") 

          spree_get :show, :id => @product.to_param
          response.body.should =~ /runtime orange/
        end
      end

      context "#is present and false" do
        it "should be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                               :virtual_path => "spree/products/show", 
                               :name => "Posts#index", 
                               :insert_after => "div", 
                               :disabled => false,
                               :text => "runtime orange") 

          spree_get :show, :id => @product.to_param
          response.body.should =~ /runtime orange/
        end
      end

      context "#is present and true" do
        it "should not be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                               :virtual_path => "spree/products/show", 
                               :name => "Posts#index", 
                               :insert_after => "div", 
                               :disabled => true,
                               :text => "from orange1") 

          spree_get :show, :id => @product.to_param
          response.body.should_not =~ /from orange1/
        end
      end
    end

    context "where multiple overrides for the same virtual_path are present" do
      context "at the base and tenant level" do
        it "should include the contents of both tenant-specific and base override" do
          Deface::Override.new(
                               :virtual_path => "spree/products/show", 
                               :name => "base Posts#index", 
                               :insert_after => "div", 
                               :text => "from base") 
          Deface::Override.new(:tenant_name => 'orange',
                               :virtual_path => "spree/products/show", 
                               :name => "orange Posts#index", 
                               :insert_after => "div", 
                               :text => "from orange2") 

          spree_get :show, :id => @product.to_param

          response.body.should =~ /from base/
          response.body.should =~ /from orange2/
        end
      end

      context "at the tenant level only" do
        it "should only include the contents of the relevant tenant-specific" do
          Deface::Override.new(:tenant_name => 'green',
                               :virtual_path => "spree/products/show", 
                               :name => "green Posts2#index", 
                               :insert_after => "div", 
                               :text => "from green") 
          Deface::Override.new(:tenant_name => 'orange',
                               :virtual_path => "spree/products/show", 
                               :name => "orange Posts2#index", 
                               :insert_after => "div", 
                               :text => "from orange3") 

          spree_get :show, :id => @product.to_param

          response.body.should_not =~ /from green/
          response.body.should =~ /from orange3/
        end
      end
    end
  end # context overrides with a tenant_name key

  context "override contains a :partial" do

    before do
      Deface::Override.new(:tenant_name => 'orange',
                           :virtual_path => "spree/products/index", 
                           :name => "partial1_index", 
                           :insert_top => "div", 
                           :partial => "shared/post")
    end

    context "#tenant-specific partial exists" do
      it "should look for the view first in the correct tenant path" do

        Spree::Tenant.set_current_tenant(@orange_tenant) 
        request.stub(:domain => 'orange.domain')          

        spree_get :index
        response.body.should_not =~ /from shared\/post partial/
        response.body.should =~ /from orange tenant partial/
      end
    end

    context "#tenant-specific partial does not exist" do
      before do
        Spree::Tenant.set_current_tenant(@green_tenant) 
        request.stub(:domain => 'green.domain')          
      end

      it "should not use a different tenant's partial" do
        spree_get :index
        response.body.should_not =~ /from orange tenant partial/
      end


      it "should use the base partial" do
        Deface::Override.new(
                           :virtual_path => "spree/products/index", 
                           :name => "partial2_index", 
                           :insert_top => "div", 
                           :partial => "shared/post")

        spree_get :index
        response.body.should =~ /from shared\/post partial/
      end

    end
  end # override contains a partial

  context "precompiled overrides exist" do
    let(:orange_precompiled_tenant_file_contents) { 'this is an precompiled orange override' }
    let(:precompiled_base_file_contents)          { 'this is a base precompiled override' }
    let(:orange_tenant_override_dir)              { 'spec/dummy/app/tenants/orange/overrides'}

    context "for this tenant" do
      it "includes the precompiled tenant-specific view" do
        
        FileUtils.rm_rf(compiled_views_dir)

        precompiled_orange_tenant_override_dir = "#{compiled_views_dir}/tenants/orange/spree/products"

        FileUtils.mkdir_p precompiled_orange_tenant_override_dir

        File.open("#{precompiled_orange_tenant_override_dir}/show.html.erb", "w") { |f|
          f.write(orange_precompiled_tenant_file_contents)
        }

        Spree::Tenant.set_current_tenant(@orange_tenant)
        request.stub(:domain => 'orange.domain')

        # make sure our product gets created w/ the correct tenant id
        product = create(:product, :available_on => 1.year.ago)

        spree_get :show, :id => product.to_param
        response.body.should =~ Regexp.new(orange_precompiled_tenant_file_contents)

        FileUtils.rm_rf("#{precompiled_orange_tenant_override_dir}/show.html.erb")
      end
    end
    context "only for global views (non-tenant-specific)" do
      it "includes only the precompiled base view" do
        FileUtils.rm_rf(compiled_views_dir)

        precompiled_base_override_dir = "#{compiled_views_dir}/spree/products"

        FileUtils.mkdir_p precompiled_base_override_dir

        File.open("#{precompiled_base_override_dir}/show.html.erb", "w") { |f|
          f.write(precompiled_base_file_contents)
        }

        # we only have overrides present for 'orange'
        Spree::Tenant.set_current_tenant(@green_tenant)
        request.stub(:domain => 'green.domain')

        # make sure our product gets created w/ the correct tenant id
        product = create(:product, :available_on => 1.year.ago)

        spree_get :show, :id => product.to_param
        response.body.should =~ Regexp.new(precompiled_base_file_contents)

        FileUtils.rm_rf("#{precompiled_base_override_dir}/show.html.erb")
      end
    end
  end # precompiled

  context "#runtime-compiled overrides" do
    context "for this tenant" do
      it "applies the correct tenant-specific override" do
        Spree::Tenant.set_current_tenant(@orange_tenant)
        request.stub(:domain => 'orange.domain')

        # make sure our product gets created w/ the correct tenant id
        product = create(:product, :available_on => 1.year.ago)

        Deface::Override.new(:tenant_name => 'orange',
                             :virtual_path => "spree/products/show", 
                             :name => "Posts#index", 
                             :insert_after => "div", 
                             :text => "runtime orange") 

        spree_get :show, :id => product.to_param
        response.body.should =~ /runtime orange/
      end
    end
    context "base-only" do
      it "applies the base override" do
        Spree::Tenant.set_current_tenant(@green_tenant)
        request.stub(:domain => 'green.domain')

        # make sure our product gets created w/ the correct tenant id
        product = create(:product, :available_on => 1.year.ago)

        Deface::Override.new(:virtual_path => "spree/products/show", 
                             :name => "greenPosts#index", 
                             :insert_after => "div", 
                             :text => "runtime base") 

        spree_get :show, :id => product.to_param
        response.body.should =~ /runtime base/
      end
    end
  end
end
