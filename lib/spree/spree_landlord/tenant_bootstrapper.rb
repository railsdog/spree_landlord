module Spree
  module SpreeLandlord
    class TenantBootstrapper
      attr_reader :first_tenant

      def run
        create_first_tenant
        create_tenants_admin_role
        notify
      end

      def create_first_tenant
        @first_tenant = Spree::Tenant.new
        @first_tenant.domain = "#{dns_friendly_app_name}.dev"
        @first_tenant.shortname = dns_friendly_app_name
        @first_tenant.save!
        @first_tenant
      end

      def create_tenants_admin_role
        role = Spree::Role.new(name: 'super_admin')
        role.tenant = first_tenant
        role.save!
        role
      end

      def notify
        puts("Created #{dns_friendly_app_name} as default Tenant")
      end

      def app_name
        Rails.application.class.parent_name
      end

      def dns_friendly_app_name
        app_name.tableize.singularize.dasherize
      end
    end
  end
end
