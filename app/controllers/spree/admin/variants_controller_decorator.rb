Spree::Admin::VariantsController.class_eval do
  def new_before
    @object.attributes = @object.product.master.attributes.except('id', 'created_at', 'deleted_at',
                                                                  'sku', 'is_master', 'count_on_hand',
                                                                  'tenant_id')
    # Shallow Clone of the default price to populate the price field.
    @object.default_price = @object.product.master.default_price.clone
  end
end
