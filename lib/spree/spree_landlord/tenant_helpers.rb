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
        tenant_path = "app/tenants/#{tenant.shortname}/views"

        root = Rails.application.root.to_s

        prepend_view_path("#{root}/#{tenant_path}")
        prepend_view_path("#{root}/#{compiled_tenant_path}")
      end
    end
  end
end
