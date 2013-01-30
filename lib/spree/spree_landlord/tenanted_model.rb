module Spree
  module SpreeLandlord
    module TenantedModel

      extend ActiveSupport::Concern

      def tenant
        tenant_attribute = read_attribute(:tenant_id)
        unless tenant_attribute.present?
          write_attribute(:tenant_id, Spree::Tenant.current_tenant_id)
        end

        super
      end

      def preference_cache_key(name)
        return unless id
        if self.class.column_names.include?('tenant_id')
          [tenant_id, self.class.name, name, id].join('::').underscore
        else
          [self.class.name, name, id].join('::').underscore
        end
      end

      included do
        attr_protected :tenant_id
        belongs_to  :tenant

        if table_exists? && column_names.include?('tenant_id')
          validates :tenant_id, presence: true
        end

        default_scope lambda {
          if Spree::Tenant.table_exists? && column_names.include?('tenant_id')
            where( "#{table_name}.tenant_id = ?", Spree::Tenant.current_tenant_id )
          end
        }

        before_validation(:on => :create) do |obj|
          if obj.class.column_names.include?('tenant_id')
            obj.tenant_id ||= Spree::Tenant.current_tenant_id
          end
        end
      end
    end
  end
end
