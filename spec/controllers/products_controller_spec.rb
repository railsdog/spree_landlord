# the goal here is to test deface-enabled tenant view paths
require 'spec_helper'

describe Spree::ProductsController do
  render_views # force view creation - http://stackoverflow.com/questions/1063073/rspec-controller-testing-blank-response-body

  let(:user) { create(:user) }

  before do
    controller.stub(:spree_current_user => user)

    Spree::Tenant.all.map(&:destroy)
    @orange_tenant = Spree::Tenant.create!(name: 'orange', shortname: 'orange', domain: 'orange.domain')
    @green_tenant =  Spree::Tenant.create!(name: 'green', shortname: 'green', domain: 'green.domain')
  end

  let(:orange_precompiled_tenant_file_contents) { 'this is an precompiled orange override' }
  let(:precompiled_base_file_contents)          { 'this is a base precompiled override' }
  let(:compiled_views_dir)                      { 'spec/dummy/app/compiled_views'}
  let(:orange_tenant_override_dir)              { 'spec/dummy/app/tenants/orange/overrides'}


  context "#index" do
    context "#precompiled overrides exist" do
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
      context "base-only" do
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
    end

    context "#runtime-compiled overrides" do
      context "for this tenant" do
        it "includes the correct tenant-specific view" do
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
        it "includes the correct base view" do
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
end
