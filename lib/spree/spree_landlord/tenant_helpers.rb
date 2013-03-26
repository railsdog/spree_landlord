module Spree
  module SpreeLandlord
    module TenantHelpers
      extend ActiveSupport::Concern

      included do
        prepend_before_filter :add_tenant_view_path
        prepend_before_filter :set_current_tenant
      end

      def set_current_tenant
        finder = TenantFinder.new
        tenant = finder.find_target_tenant(request)
        Spree::Tenant.set_current_tenant(tenant)
      end

      def add_tenant_view_path
        tenant = Tenant.current_tenant
        path = "app/tenants/#{tenant.shortname}/views"
        prepend_view_path(path)
      end
    end
  end
end
