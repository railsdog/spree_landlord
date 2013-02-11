require 'spec_helper'

module Deface
  describe Precompiler do

    # make sure we have a couple different tenants
    before do
      Spree::Tenant.all.map(&:destroy)
      Spree::Tenant.create!(name: 'orange', shortname: 'orange', domain: 'foo.com')
      Spree::Tenant.create!(name: 'green', shortname: 'green', domain: 'foo2.com')

      FileUtils.rm_rf('spec/dummy/app/compiled_views')
      Precompiler.precompile()
    end

    after do
      # stop clobbering other tests relying on these specific tenant names
      Spree::Tenant.all.map(&:destroy) 

      # cleanup the file system
      FileUtils.rm_rf('spec/dummy/app/compiled_views')
    end

    context "#tenant_name present" do
      it "writes into tenant directory" do
        filename = 'spec/dummy/app/compiled_views/tenants/orange/posts/index.html.erb'
        File.exists?(filename).should be_true

        file = File.open(filename, "rb")
        contents = file.read

        contents.should =~ /Added non_dsl orange to li/
        contents.should_not =~ /Added non_dsl green to li/  # make sure we only pick up the relevant tenant override
        contents.should =~ /Added to li/ # make sure we pick up the base override as well
      end
    end

    context "#tenant_name not present" do
      it "writes into base directory" do
        filename = 'spec/dummy/app/compiled_views/posts/index.html.erb'

        File.exists?(filename).should be_true

        file = File.open(filename, "rb")
        contents = file.read

        contents.should =~ /Added to li/
      end
    end
  end #precompiled overrides
end
