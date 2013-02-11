require 'spec_helper'

$initial_overrides = Rails.application.config.deface.overrides.all.dup

module Deface
  describe "overrides" do
    before {
      Spree::Tenant.all.map(&:destroy)
      Rails.application.config.deface.overrides.all.clear
    }

    let(:orange_tenant) { Spree::Tenant.create!(name: 'orange', shortname: 'orange', domain: 'foo3.com') }
    let(:green_tenant) { Spree::Tenant.create!(name: 'green', shortname: 'green', domain: 'foo2.com') }

    let(:source) { "<h1>World</h1><p>Hello</p>" }

    context "with a 'tenant_name' key" do
      before { Spree::Tenant.set_current_tenant(orange_tenant) }

      context "without disabled specified" do
        it "should be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                           :virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1") 
          
          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == "<h1>World</h1><p>Hello</p><h1>World</h1>"
        end
      end
      context "#disabled flag explicitly marked false" do
        it "should be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                           :virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1",
                           :disabled => false) 

          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == "<h1>World</h1><p>Hello</p><h1>World</h1>"
        end
      end
      context "#disabled flag explicitly marked true" do
        it "should not be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                           :virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1",
                           :disabled => true) 

          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == source
        end
      end

      context "where multiple overrides for the same virtual_path are present" do
        context "at the base and tenant level" do
          it "should include the contents of both tenant-specific and base override" do
            Deface::Override.new(:virtual_path => "posts/index", 
                                 :name => "base Posts#index", 
                                 :insert_after => "p", 
                                 :text => "from base") 
            Deface::Override.new(:tenant_name => 'orange',
                                 :virtual_path => "posts/index", 
                                 :name => "orange Posts#index", 
                                 :insert_after => "p", 
                                 :text => "from orange") 

            results = DefaceDummy.apply(source, 
                                        {:virtual_path => "posts/index"}
                                        )
            results.should =~ /from base/
            results.should =~ /from orange/
          end
        end

        context "at the tenant level only" do
          it "should only include the contents of the relevant tenant-specific" do
            Deface::Override.new(:tenant_name => 'green',
                                 :virtual_path => "posts/index", 
                                 :name => "green Posts#index", 
                                 :insert_after => "p", 
                                 :text => "from green") 
            Deface::Override.new(:tenant_name => 'orange',
                                 :virtual_path => "posts/index", 
                                 :name => "orange Posts#index", 
                                 :insert_after => "p", 
                                 :text => "from orange") 

            results = DefaceDummy.apply(source, 
                                        {:virtual_path => "posts/index"}
                                        )
            results.should_not =~ /from green/
            results.should =~ /from orange/
          end
        end
      end
    end #current tenant_name present

    context "#other tenant tenant_name present" do
      before {
        Spree::Tenant.set_current_tenant(green_tenant)
      }

      context "#disabled flag not included" do
        it "should not be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                           :virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1") 
          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == source
        end
      end
      context "#disabled flag explicitly marked false" do
        it "should not be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                           :virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1",
                           :disabled => false) 
          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == source
        end
      end
      context "#disabled flag explicitly marked true" do
        it "should not be applied" do
          Deface::Override.new(:tenant_name => 'orange',
                               :virtual_path => "posts/index", 
                               :name => "Posts#index", 
                               :insert_after => "p", 
                               :copy => "h1",
                               :disabled => true) 
          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == source
        end
      end    
    end
    
    context "#tenant_name not present" do
      context "#disabled flag not included" do
        it "should be applied" do
          Deface::Override.new(:virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1") 
          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == "<h1>World</h1><p>Hello</p><h1>World</h1>"
        end
      end
      context "#disabled flag explicitly marked false" do
        it "should be applied" do
          Deface::Override.new(:virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1",
                           :disabled => false) 
          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == "<h1>World</h1><p>Hello</p><h1>World</h1>"
        end
      end
      context "#disabled flag explicitly marked true" do
        it "should not be applied" do
          Deface::Override.new(:virtual_path => "posts/index", 
                           :name => "Posts#index", 
                           :insert_after => "p", 
                           :copy => "h1",
                           :disabled => true) 
          DefaceDummy.apply(source, 
                      {:virtual_path => "posts/index"}
                      ).should == source
        end
      end        
    end
    # controls directory name for precompiled overrides
  end # overrides


  describe "dsl overrides" do
    before do
      Rails.application.config.deface.overrides.all = $initial_overrides.dup
    end

    context "#tenanted override present" do
      context "html.erb" do
        it "should have tenant_name as part of the override" do
          @override = Deface::Override.find(:virtual_path => "posts/dslerb").first
          @override.args[:tenant_name].should == "erborange"
        end
      end

      context "html.haml" do
        it "should have tenant_name as part of the override" do
          @override = Deface::Override.find(:virtual_path => "posts/dslhaml").first
          @override.args[:tenant_name].should == "hamlorange"
        end
      end

      context ".deface" do
        it "should have tenant_name as part of the override" do
          @override = Deface::Override.find(:virtual_path => "posts/dsldeface").first
          @override.args[:tenant_name].should == "defaceorange"
        end
      end
    end
  end
end
