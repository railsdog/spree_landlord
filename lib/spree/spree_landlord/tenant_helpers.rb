module Spree
  module SpreeLandlord
    module TenantHelpers
      extend ActiveSupport::Concern

      included do
        before_filter :set_current_tenant
        before_filter :add_tenant_view_path
      end

      def set_current_tenant
        finder = TenantFinder.new
        tenant = finder.find_target_tenant(request)
        Spree::Tenant.set_current_tenant(tenant)
      end

      def add_tenant_view_path
        tenant = Tenant.current_tenant

        compiled_tenant_path = "app/compiled_views/tenants/#{tenant.shortname}"
        #tenant_path = "app/tenants/#{tenant.shortname}/views"  #### wait, isn't this already taken care of by landlord???? i think yes

        # Let's prepend all the (railtie-aware) compiled_views paths to the absolute front of the list.

        # They are already in the view path, but we need to make sure they show up
        # before our tenant-specific paths
        # reversing the railtie order so that I preserve Gemfile ordering
        # (i think/guess the '.all' gives me that ordering????)
        Rails.application.railties.all.reverse.each do |railtie|
          next unless railtie.respond_to? :root

          root = railtie.root.to_s
          prepend_view_path("#{root}/#{compiled_tenant_path}")
        end

        # make sure the application's paths occur first, by prepending last
        root = Rails.application.root.to_s
        prepend_view_path("#{root}/#{compiled_tenant_path}")
      end
    end
  end
end
