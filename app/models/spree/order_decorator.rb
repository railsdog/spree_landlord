module Spree
  Order.class_eval do
    def clone_billing_address
      if bill_address and self.ship_address.nil?
        self.ship_address = bill_address.clone
      else
        self.ship_address.attributes = bill_address.attributes.except('id', 'updated_at', 'created_at', 'tenant_id')
        self.ship_address.tenant_id = bill_address.tenant_id
      end
      true
    end
  end
end
