module Spree
  Address.class_eval do
    def clone
      cloned_address = self.class.new(self.attributes.except('id', 'updated_at', 'created_at', 'tenant_id'))
      cloned_address.tenant_id = self.attributes['tenant_id']
      cloned_address
    end
  end
end
