module Deface
  Override.class_eval do
    def disabled?
      tenant_match = true

      if @args.key?(:tenant_name)
        tenant_match = (@args[:tenant_name] == Spree::Tenant.current_tenant.shortname ? true : false)
      end

      (@args.key?(:disabled) ? @args[:disabled] : false) || !tenant_match
    end
  end
end

